-- Run against the commerce database with psql -v ON_ERROR_STOP=1 after a backup.
-- Idempotent: only image URLs using the retired Docker origin are rewritten.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

CREATE FUNCTION pg_temp.repair_inventory_image_json(data jsonb) RETURNS jsonb
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE result jsonb; value text;
BEGIN
  CASE jsonb_typeof(data)
    WHEN 'string' THEN
      value := data #>> '{}';
      IF value LIKE 'http://medusa:9000/bayblaze/inventory-images/%' THEN
        RETURN to_jsonb('https://api.bayblaze.net' || substr(value, length('http://medusa:9000') + 1));
      END IF;
      RETURN data;
    WHEN 'array' THEN
      SELECT coalesce(jsonb_agg(pg_temp.repair_inventory_image_json(item) ORDER BY position), '[]'::jsonb)
        INTO result FROM jsonb_array_elements(data) WITH ORDINALITY AS items(item, position);
      RETURN result;
    WHEN 'object' THEN
      SELECT coalesce(jsonb_object_agg(fields.key, pg_temp.repair_inventory_image_json(fields.item)), '{}'::jsonb)
        INTO result FROM jsonb_each(data) AS fields(key, item);
      RETURN result;
    ELSE RETURN data;
  END CASE;
END;
$$;

DO $$
DECLARE entry record; affected bigint;
BEGIN
  FOR entry IN
    SELECT table_name, column_name FROM information_schema.columns
    WHERE table_schema = 'public'
      AND (column_name = 'thumbnail' OR
        (table_name IN ('image', 'order_claim_item_image') AND column_name = 'url'))
      AND data_type IN ('text', 'character varying')
  LOOP
    EXECUTE format(
      'UPDATE %I SET %I = $1 || substr(%I, length($2) + 1), updated_at = now() WHERE %I LIKE $2 || ''/%%''',
      entry.table_name, entry.column_name, entry.column_name, entry.column_name
    ) USING 'https://api.bayblaze.net', 'http://medusa:9000';
    GET DIAGNOSTICS affected = ROW_COUNT;
    RAISE NOTICE 'Repaired %.%: % rows', entry.table_name, entry.column_name, affected;
  END LOOP;

  FOR entry IN
    SELECT table_name FROM information_schema.columns
    WHERE table_schema = 'public' AND column_name = 'metadata' AND data_type = 'jsonb'
      AND table_name IN ('product', 'product_variant', 'image', 'inventory_item', 'cart_line_item', 'order_line_item')
  LOOP
    EXECUTE format(
      'UPDATE %I SET metadata = pg_temp.repair_inventory_image_json(metadata), updated_at = now() WHERE metadata IS DISTINCT FROM pg_temp.repair_inventory_image_json(metadata)',
      entry.table_name
    );
    GET DIAGNOSTICS affected = ROW_COUNT;
    RAISE NOTICE 'Repaired %.metadata: % rows', entry.table_name, affected;
  END LOOP;
END;
$$;
COMMIT;
