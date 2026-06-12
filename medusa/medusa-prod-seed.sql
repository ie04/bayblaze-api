--
-- PostgreSQL database dump
--

\restrict MLshGL83OgbxB71QPdgtb442iuLN1F3zW2YPs80alfxrPKkRKsMdi4z6KxwEeLK

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.store_locale DROP CONSTRAINT IF EXISTS store_locale_store_id_foreign;
ALTER TABLE IF EXISTS ONLY public.store_currency DROP CONSTRAINT IF EXISTS store_currency_store_id_foreign;
ALTER TABLE IF EXISTS ONLY public.stock_location DROP CONSTRAINT IF EXISTS stock_location_address_id_foreign;
ALTER TABLE IF EXISTS ONLY public.shipping_option DROP CONSTRAINT IF EXISTS shipping_option_shipping_profile_id_foreign;
ALTER TABLE IF EXISTS ONLY public.shipping_option DROP CONSTRAINT IF EXISTS shipping_option_shipping_option_type_id_foreign;
ALTER TABLE IF EXISTS ONLY public.shipping_option DROP CONSTRAINT IF EXISTS shipping_option_service_zone_id_foreign;
ALTER TABLE IF EXISTS ONLY public.shipping_option_rule DROP CONSTRAINT IF EXISTS shipping_option_rule_shipping_option_id_foreign;
ALTER TABLE IF EXISTS ONLY public.shipping_option DROP CONSTRAINT IF EXISTS shipping_option_provider_id_foreign;
ALTER TABLE IF EXISTS ONLY public.service_zone DROP CONSTRAINT IF EXISTS service_zone_fulfillment_set_id_foreign;
ALTER TABLE IF EXISTS ONLY public.return_reason DROP CONSTRAINT IF EXISTS return_reason_parent_return_reason_id_foreign;
ALTER TABLE IF EXISTS ONLY public.reservation_item DROP CONSTRAINT IF EXISTS reservation_item_inventory_item_id_foreign;
ALTER TABLE IF EXISTS ONLY public.region_country DROP CONSTRAINT IF EXISTS region_country_region_id_foreign;
ALTER TABLE IF EXISTS ONLY public.refund DROP CONSTRAINT IF EXISTS refund_payment_id_foreign;
ALTER TABLE IF EXISTS ONLY public.provider_identity DROP CONSTRAINT IF EXISTS provider_identity_auth_identity_id_foreign;
ALTER TABLE IF EXISTS ONLY public.promotion_rule_value DROP CONSTRAINT IF EXISTS promotion_rule_value_promotion_rule_id_foreign;
ALTER TABLE IF EXISTS ONLY public.promotion_promotion_rule DROP CONSTRAINT IF EXISTS promotion_promotion_rule_promotion_rule_id_foreign;
ALTER TABLE IF EXISTS ONLY public.promotion_promotion_rule DROP CONSTRAINT IF EXISTS promotion_promotion_rule_promotion_id_foreign;
ALTER TABLE IF EXISTS ONLY public.promotion DROP CONSTRAINT IF EXISTS promotion_campaign_id_foreign;
ALTER TABLE IF EXISTS ONLY public.promotion_campaign_budget_usage DROP CONSTRAINT IF EXISTS promotion_campaign_budget_usage_budget_id_foreign;
ALTER TABLE IF EXISTS ONLY public.promotion_campaign_budget DROP CONSTRAINT IF EXISTS promotion_campaign_budget_campaign_id_foreign;
ALTER TABLE IF EXISTS ONLY public.promotion_application_method DROP CONSTRAINT IF EXISTS promotion_application_method_promotion_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_variant_product_image DROP CONSTRAINT IF EXISTS product_variant_product_image_image_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_variant DROP CONSTRAINT IF EXISTS product_variant_product_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_variant_option DROP CONSTRAINT IF EXISTS product_variant_option_variant_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_variant_option DROP CONSTRAINT IF EXISTS product_variant_option_option_value_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product DROP CONSTRAINT IF EXISTS product_type_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_tags DROP CONSTRAINT IF EXISTS product_tags_product_tag_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_tags DROP CONSTRAINT IF EXISTS product_tags_product_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_option_value DROP CONSTRAINT IF EXISTS product_option_value_option_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_option DROP CONSTRAINT IF EXISTS product_option_product_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product DROP CONSTRAINT IF EXISTS product_collection_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_category_product DROP CONSTRAINT IF EXISTS product_category_product_product_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_category_product DROP CONSTRAINT IF EXISTS product_category_product_product_category_id_foreign;
ALTER TABLE IF EXISTS ONLY public.product_category DROP CONSTRAINT IF EXISTS product_category_parent_category_id_foreign;
ALTER TABLE IF EXISTS ONLY public.price_rule DROP CONSTRAINT IF EXISTS price_rule_price_id_foreign;
ALTER TABLE IF EXISTS ONLY public.price DROP CONSTRAINT IF EXISTS price_price_set_id_foreign;
ALTER TABLE IF EXISTS ONLY public.price DROP CONSTRAINT IF EXISTS price_price_list_id_foreign;
ALTER TABLE IF EXISTS ONLY public.price_list_rule DROP CONSTRAINT IF EXISTS price_list_rule_price_list_id_foreign;
ALTER TABLE IF EXISTS ONLY public.payment_session DROP CONSTRAINT IF EXISTS payment_session_payment_collection_id_foreign;
ALTER TABLE IF EXISTS ONLY public.payment DROP CONSTRAINT IF EXISTS payment_payment_collection_id_foreign;
ALTER TABLE IF EXISTS ONLY public.payment_collection_payment_providers DROP CONSTRAINT IF EXISTS payment_collection_payment_providers_payment_pro_2d555_foreign;
ALTER TABLE IF EXISTS ONLY public.payment_collection_payment_providers DROP CONSTRAINT IF EXISTS payment_collection_payment_providers_payment_col_aa276_foreign;
ALTER TABLE IF EXISTS ONLY public.order_transaction DROP CONSTRAINT IF EXISTS order_transaction_order_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_summary DROP CONSTRAINT IF EXISTS order_summary_order_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_shipping DROP CONSTRAINT IF EXISTS order_shipping_order_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_shipping_method_tax_line DROP CONSTRAINT IF EXISTS order_shipping_method_tax_line_shipping_method_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_shipping_method_adjustment DROP CONSTRAINT IF EXISTS order_shipping_method_adjustment_shipping_method_id_foreign;
ALTER TABLE IF EXISTS ONLY public."order" DROP CONSTRAINT IF EXISTS order_shipping_address_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_line_item DROP CONSTRAINT IF EXISTS order_line_item_totals_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_line_item_tax_line DROP CONSTRAINT IF EXISTS order_line_item_tax_line_item_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_line_item_adjustment DROP CONSTRAINT IF EXISTS order_line_item_adjustment_item_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_item DROP CONSTRAINT IF EXISTS order_item_order_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_item DROP CONSTRAINT IF EXISTS order_item_item_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_credit_line DROP CONSTRAINT IF EXISTS order_credit_line_order_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_change DROP CONSTRAINT IF EXISTS order_change_order_id_foreign;
ALTER TABLE IF EXISTS ONLY public.order_change_action DROP CONSTRAINT IF EXISTS order_change_action_order_change_id_foreign;
ALTER TABLE IF EXISTS ONLY public."order" DROP CONSTRAINT IF EXISTS order_billing_address_id_foreign;
ALTER TABLE IF EXISTS ONLY public.notification DROP CONSTRAINT IF EXISTS notification_provider_id_foreign;
ALTER TABLE IF EXISTS ONLY public.inventory_level DROP CONSTRAINT IF EXISTS inventory_level_inventory_item_id_foreign;
ALTER TABLE IF EXISTS ONLY public.image DROP CONSTRAINT IF EXISTS image_product_id_foreign;
ALTER TABLE IF EXISTS ONLY public.geo_zone DROP CONSTRAINT IF EXISTS geo_zone_service_zone_id_foreign;
ALTER TABLE IF EXISTS ONLY public.fulfillment DROP CONSTRAINT IF EXISTS fulfillment_shipping_option_id_foreign;
ALTER TABLE IF EXISTS ONLY public.fulfillment DROP CONSTRAINT IF EXISTS fulfillment_provider_id_foreign;
ALTER TABLE IF EXISTS ONLY public.fulfillment_label DROP CONSTRAINT IF EXISTS fulfillment_label_fulfillment_id_foreign;
ALTER TABLE IF EXISTS ONLY public.fulfillment_item DROP CONSTRAINT IF EXISTS fulfillment_item_fulfillment_id_foreign;
ALTER TABLE IF EXISTS ONLY public.fulfillment DROP CONSTRAINT IF EXISTS fulfillment_delivery_address_id_foreign;
ALTER TABLE IF EXISTS ONLY public.customer_group_customer DROP CONSTRAINT IF EXISTS customer_group_customer_customer_id_foreign;
ALTER TABLE IF EXISTS ONLY public.customer_group_customer DROP CONSTRAINT IF EXISTS customer_group_customer_customer_group_id_foreign;
ALTER TABLE IF EXISTS ONLY public.customer_address DROP CONSTRAINT IF EXISTS customer_address_customer_id_foreign;
ALTER TABLE IF EXISTS ONLY public.credit_line DROP CONSTRAINT IF EXISTS credit_line_cart_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart_shipping_method_tax_line DROP CONSTRAINT IF EXISTS cart_shipping_method_tax_line_shipping_method_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart_shipping_method DROP CONSTRAINT IF EXISTS cart_shipping_method_cart_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart_shipping_method_adjustment DROP CONSTRAINT IF EXISTS cart_shipping_method_adjustment_shipping_method_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart DROP CONSTRAINT IF EXISTS cart_shipping_address_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart_line_item_tax_line DROP CONSTRAINT IF EXISTS cart_line_item_tax_line_item_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart_line_item DROP CONSTRAINT IF EXISTS cart_line_item_cart_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart_line_item_adjustment DROP CONSTRAINT IF EXISTS cart_line_item_adjustment_item_id_foreign;
ALTER TABLE IF EXISTS ONLY public.cart DROP CONSTRAINT IF EXISTS cart_billing_address_id_foreign;
ALTER TABLE IF EXISTS ONLY public.capture DROP CONSTRAINT IF EXISTS capture_payment_id_foreign;
ALTER TABLE IF EXISTS ONLY public.application_method_target_rules DROP CONSTRAINT IF EXISTS application_method_target_rules_promotion_rule_id_foreign;
ALTER TABLE IF EXISTS ONLY public.application_method_target_rules DROP CONSTRAINT IF EXISTS application_method_target_rules_application_method_id_foreign;
ALTER TABLE IF EXISTS ONLY public.application_method_buy_rules DROP CONSTRAINT IF EXISTS application_method_buy_rules_promotion_rule_id_foreign;
ALTER TABLE IF EXISTS ONLY public.application_method_buy_rules DROP CONSTRAINT IF EXISTS application_method_buy_rules_application_method_id_foreign;
ALTER TABLE IF EXISTS ONLY public.tax_region DROP CONSTRAINT IF EXISTS "FK_tax_region_provider_id";
ALTER TABLE IF EXISTS ONLY public.tax_region DROP CONSTRAINT IF EXISTS "FK_tax_region_parent_id";
ALTER TABLE IF EXISTS ONLY public.tax_rate DROP CONSTRAINT IF EXISTS "FK_tax_rate_tax_region_id";
ALTER TABLE IF EXISTS ONLY public.tax_rate_rule DROP CONSTRAINT IF EXISTS "FK_tax_rate_rule_tax_rate_id";
DROP INDEX IF EXISTS public.idx_script_name_unique;
DROP INDEX IF EXISTS public."IDX_workflow_execution_workflow_id_transaction_id_run_id_unique";
DROP INDEX IF EXISTS public."IDX_workflow_execution_workflow_id_transaction_id";
DROP INDEX IF EXISTS public."IDX_workflow_execution_workflow_id";
DROP INDEX IF EXISTS public."IDX_workflow_execution_updated_at_retention_time";
DROP INDEX IF EXISTS public."IDX_workflow_execution_transaction_id";
DROP INDEX IF EXISTS public."IDX_workflow_execution_state_updated_at";
DROP INDEX IF EXISTS public."IDX_workflow_execution_state";
DROP INDEX IF EXISTS public."IDX_workflow_execution_run_id";
DROP INDEX IF EXISTS public."IDX_workflow_execution_retention_time_updated_at_state";
DROP INDEX IF EXISTS public."IDX_workflow_execution_id";
DROP INDEX IF EXISTS public."IDX_workflow_execution_deleted_at";
DROP INDEX IF EXISTS public."IDX_view_configuration_user_id";
DROP INDEX IF EXISTS public."IDX_view_configuration_entity_user_id";
DROP INDEX IF EXISTS public."IDX_view_configuration_entity_is_system_default";
DROP INDEX IF EXISTS public."IDX_view_configuration_deleted_at";
DROP INDEX IF EXISTS public."IDX_variant_id_52b23597";
DROP INDEX IF EXISTS public."IDX_variant_id_17b4c4e35";
DROP INDEX IF EXISTS public."IDX_user_preference_user_id_key_unique";
DROP INDEX IF EXISTS public."IDX_user_preference_user_id";
DROP INDEX IF EXISTS public."IDX_user_preference_deleted_at";
DROP INDEX IF EXISTS public."IDX_user_id_64ff0c4c";
DROP INDEX IF EXISTS public."IDX_user_email_unique";
DROP INDEX IF EXISTS public."IDX_user_deleted_at";
DROP INDEX IF EXISTS public."IDX_unique_promotion_code";
DROP INDEX IF EXISTS public."IDX_type_value_unique";
DROP INDEX IF EXISTS public."IDX_tax_region_unique_country_province";
DROP INDEX IF EXISTS public."IDX_tax_region_unique_country_nullable_province";
DROP INDEX IF EXISTS public."IDX_tax_region_provider_id";
DROP INDEX IF EXISTS public."IDX_tax_region_parent_id";
DROP INDEX IF EXISTS public."IDX_tax_region_deleted_at";
DROP INDEX IF EXISTS public."IDX_tax_rate_tax_region_id";
DROP INDEX IF EXISTS public."IDX_tax_rate_rule_unique_rate_reference";
DROP INDEX IF EXISTS public."IDX_tax_rate_rule_tax_rate_id";
DROP INDEX IF EXISTS public."IDX_tax_rate_rule_reference_id";
DROP INDEX IF EXISTS public."IDX_tax_rate_rule_deleted_at";
DROP INDEX IF EXISTS public."IDX_tax_rate_deleted_at";
DROP INDEX IF EXISTS public."IDX_tax_provider_deleted_at";
DROP INDEX IF EXISTS public."IDX_tag_value_unique";
DROP INDEX IF EXISTS public."IDX_store_locale_store_id";
DROP INDEX IF EXISTS public."IDX_store_locale_deleted_at";
DROP INDEX IF EXISTS public."IDX_store_deleted_at";
DROP INDEX IF EXISTS public."IDX_store_currency_store_id";
DROP INDEX IF EXISTS public."IDX_store_currency_deleted_at";
DROP INDEX IF EXISTS public."IDX_stock_location_id_26d06f470";
DROP INDEX IF EXISTS public."IDX_stock_location_id_-e88adb96";
DROP INDEX IF EXISTS public."IDX_stock_location_id_-1e5992737";
DROP INDEX IF EXISTS public."IDX_stock_location_deleted_at";
DROP INDEX IF EXISTS public."IDX_stock_location_address_id_unique";
DROP INDEX IF EXISTS public."IDX_stock_location_address_deleted_at";
DROP INDEX IF EXISTS public."IDX_single_default_region";
DROP INDEX IF EXISTS public."IDX_shipping_profile_name_unique";
DROP INDEX IF EXISTS public."IDX_shipping_profile_id_17a262437";
DROP INDEX IF EXISTS public."IDX_shipping_profile_deleted_at";
DROP INDEX IF EXISTS public."IDX_shipping_option_type_deleted_at";
DROP INDEX IF EXISTS public."IDX_shipping_option_shipping_profile_id";
DROP INDEX IF EXISTS public."IDX_shipping_option_shipping_option_type_id";
DROP INDEX IF EXISTS public."IDX_shipping_option_service_zone_id";
DROP INDEX IF EXISTS public."IDX_shipping_option_rule_shipping_option_id";
DROP INDEX IF EXISTS public."IDX_shipping_option_rule_deleted_at";
DROP INDEX IF EXISTS public."IDX_shipping_option_provider_id";
DROP INDEX IF EXISTS public."IDX_shipping_option_id_ba32fa9c";
DROP INDEX IF EXISTS public."IDX_shipping_option_deleted_at";
DROP INDEX IF EXISTS public."IDX_shipping_method_tax_line_tax_rate_id";
DROP INDEX IF EXISTS public."IDX_shipping_method_option_id";
DROP INDEX IF EXISTS public."IDX_shipping_method_adjustment_promotion_id";
DROP INDEX IF EXISTS public."IDX_service_zone_name_unique";
DROP INDEX IF EXISTS public."IDX_service_zone_fulfillment_set_id";
DROP INDEX IF EXISTS public."IDX_service_zone_deleted_at";
DROP INDEX IF EXISTS public."IDX_sales_channel_id_26d06f470";
DROP INDEX IF EXISTS public."IDX_sales_channel_id_20b454295";
DROP INDEX IF EXISTS public."IDX_sales_channel_id_-1d67bae40";
DROP INDEX IF EXISTS public."IDX_sales_channel_deleted_at";
DROP INDEX IF EXISTS public."IDX_return_reason_value";
DROP INDEX IF EXISTS public."IDX_return_reason_parent_return_reason_id";
DROP INDEX IF EXISTS public."IDX_return_order_id";
DROP INDEX IF EXISTS public."IDX_return_item_return_id";
DROP INDEX IF EXISTS public."IDX_return_item_reason_id";
DROP INDEX IF EXISTS public."IDX_return_item_item_id";
DROP INDEX IF EXISTS public."IDX_return_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_return_id_-31ea43a";
DROP INDEX IF EXISTS public."IDX_return_exchange_id";
DROP INDEX IF EXISTS public."IDX_return_display_id";
DROP INDEX IF EXISTS public."IDX_return_claim_id";
DROP INDEX IF EXISTS public."IDX_reservation_item_location_id";
DROP INDEX IF EXISTS public."IDX_reservation_item_line_item_id";
DROP INDEX IF EXISTS public."IDX_reservation_item_inventory_item_id";
DROP INDEX IF EXISTS public."IDX_reservation_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_region_id_1c934dab0";
DROP INDEX IF EXISTS public."IDX_region_deleted_at";
DROP INDEX IF EXISTS public."IDX_region_country_region_id_iso_2_unique";
DROP INDEX IF EXISTS public."IDX_region_country_region_id";
DROP INDEX IF EXISTS public."IDX_region_country_deleted_at";
DROP INDEX IF EXISTS public."IDX_refund_refund_reason_id";
DROP INDEX IF EXISTS public."IDX_refund_reason_deleted_at";
DROP INDEX IF EXISTS public."IDX_refund_payment_id";
DROP INDEX IF EXISTS public."IDX_refund_deleted_at";
DROP INDEX IF EXISTS public."IDX_rbac_role_id_64ff0c4c";
DROP INDEX IF EXISTS public."IDX_rbac_role_id_-85069d44";
DROP INDEX IF EXISTS public."IDX_publishable_key_id_-1d67bae40";
DROP INDEX IF EXISTS public."IDX_provider_identity_provider_entity_id";
DROP INDEX IF EXISTS public."IDX_provider_identity_deleted_at";
DROP INDEX IF EXISTS public."IDX_provider_identity_auth_identity_id";
DROP INDEX IF EXISTS public."IDX_property_label_entity_property_unique";
DROP INDEX IF EXISTS public."IDX_property_label_entity";
DROP INDEX IF EXISTS public."IDX_property_label_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_type";
DROP INDEX IF EXISTS public."IDX_promotion_status";
DROP INDEX IF EXISTS public."IDX_promotion_rule_value_value";
DROP INDEX IF EXISTS public."IDX_promotion_rule_value_rule_id_value";
DROP INDEX IF EXISTS public."IDX_promotion_rule_value_promotion_rule_id";
DROP INDEX IF EXISTS public."IDX_promotion_rule_value_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_rule_operator";
DROP INDEX IF EXISTS public."IDX_promotion_rule_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_rule_attribute_operator_id";
DROP INDEX IF EXISTS public."IDX_promotion_rule_attribute_operator";
DROP INDEX IF EXISTS public."IDX_promotion_rule_attribute";
DROP INDEX IF EXISTS public."IDX_promotion_is_automatic";
DROP INDEX IF EXISTS public."IDX_promotion_id_-a9d4a70b";
DROP INDEX IF EXISTS public."IDX_promotion_id_-71518339";
DROP INDEX IF EXISTS public."IDX_promotion_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_id";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_campaign_identifier_unique";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_budget_usage_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_budget_usage_budget_id";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_budget_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_campaign_budget_campaign_id_unique";
DROP INDEX IF EXISTS public."IDX_promotion_application_method_promotion_id_unique";
DROP INDEX IF EXISTS public."IDX_promotion_application_method_deleted_at";
DROP INDEX IF EXISTS public."IDX_promotion_application_method_currency_code";
DROP INDEX IF EXISTS public."IDX_product_variant_upc_unique";
DROP INDEX IF EXISTS public."IDX_product_variant_sku_unique";
DROP INDEX IF EXISTS public."IDX_product_variant_product_image_variant_id";
DROP INDEX IF EXISTS public."IDX_product_variant_product_image_image_id";
DROP INDEX IF EXISTS public."IDX_product_variant_product_image_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_variant_product_id";
DROP INDEX IF EXISTS public."IDX_product_variant_id_product_id";
DROP INDEX IF EXISTS public."IDX_product_variant_ean_unique";
DROP INDEX IF EXISTS public."IDX_product_variant_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_variant_barcode_unique";
DROP INDEX IF EXISTS public."IDX_product_type_id";
DROP INDEX IF EXISTS public."IDX_product_type_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_tag_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_status";
DROP INDEX IF EXISTS public."IDX_product_option_value_option_id";
DROP INDEX IF EXISTS public."IDX_product_option_value_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_option_product_id";
DROP INDEX IF EXISTS public."IDX_product_option_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_image_url_rank_product_id";
DROP INDEX IF EXISTS public."IDX_product_image_url";
DROP INDEX IF EXISTS public."IDX_product_image_rank_product_id";
DROP INDEX IF EXISTS public."IDX_product_image_rank";
DROP INDEX IF EXISTS public."IDX_product_id_20b454295";
DROP INDEX IF EXISTS public."IDX_product_id_17a262437";
DROP INDEX IF EXISTS public."IDX_product_handle_unique";
DROP INDEX IF EXISTS public."IDX_product_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_collection_id";
DROP INDEX IF EXISTS public."IDX_product_collection_deleted_at";
DROP INDEX IF EXISTS public."IDX_product_category_path";
DROP INDEX IF EXISTS public."IDX_product_category_parent_category_id";
DROP INDEX IF EXISTS public."IDX_price_set_id_ba32fa9c";
DROP INDEX IF EXISTS public."IDX_price_set_id_52b23597";
DROP INDEX IF EXISTS public."IDX_price_set_deleted_at";
DROP INDEX IF EXISTS public."IDX_price_rule_price_id_attribute_operator_unique";
DROP INDEX IF EXISTS public."IDX_price_rule_price_id";
DROP INDEX IF EXISTS public."IDX_price_rule_operator_value";
DROP INDEX IF EXISTS public."IDX_price_rule_operator";
DROP INDEX IF EXISTS public."IDX_price_rule_deleted_at";
DROP INDEX IF EXISTS public."IDX_price_rule_attribute_value_price_id";
DROP INDEX IF EXISTS public."IDX_price_rule_attribute_value";
DROP INDEX IF EXISTS public."IDX_price_rule_attribute";
DROP INDEX IF EXISTS public."IDX_price_price_set_id";
DROP INDEX IF EXISTS public."IDX_price_price_list_id";
DROP INDEX IF EXISTS public."IDX_price_preference_deleted_at";
DROP INDEX IF EXISTS public."IDX_price_preference_attribute_value";
DROP INDEX IF EXISTS public."IDX_price_list_rule_value";
DROP INDEX IF EXISTS public."IDX_price_list_rule_price_list_id";
DROP INDEX IF EXISTS public."IDX_price_list_rule_deleted_at";
DROP INDEX IF EXISTS public."IDX_price_list_rule_attribute";
DROP INDEX IF EXISTS public."IDX_price_list_id_status_starts_at_ends_at";
DROP INDEX IF EXISTS public."IDX_price_list_deleted_at";
DROP INDEX IF EXISTS public."IDX_price_deleted_at";
DROP INDEX IF EXISTS public."IDX_price_currency_code";
DROP INDEX IF EXISTS public."IDX_payment_session_payment_collection_id";
DROP INDEX IF EXISTS public."IDX_payment_session_deleted_at";
DROP INDEX IF EXISTS public."IDX_payment_provider_id_1c934dab0";
DROP INDEX IF EXISTS public."IDX_payment_provider_id";
DROP INDEX IF EXISTS public."IDX_payment_provider_deleted_at";
DROP INDEX IF EXISTS public."IDX_payment_payment_session_id_unique";
DROP INDEX IF EXISTS public."IDX_payment_payment_session_id";
DROP INDEX IF EXISTS public."IDX_payment_payment_collection_id";
DROP INDEX IF EXISTS public."IDX_payment_deleted_at";
DROP INDEX IF EXISTS public."IDX_payment_collection_id_f42b9949";
DROP INDEX IF EXISTS public."IDX_payment_collection_id_-4a39f6c9";
DROP INDEX IF EXISTS public."IDX_payment_collection_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_transaction_return_id";
DROP INDEX IF EXISTS public."IDX_order_transaction_reference_id";
DROP INDEX IF EXISTS public."IDX_order_transaction_order_id_version";
DROP INDEX IF EXISTS public."IDX_order_transaction_order_id";
DROP INDEX IF EXISTS public."IDX_order_transaction_exchange_id";
DROP INDEX IF EXISTS public."IDX_order_transaction_currency_code";
DROP INDEX IF EXISTS public."IDX_order_transaction_claim_id";
DROP INDEX IF EXISTS public."IDX_order_summary_order_id_version";
DROP INDEX IF EXISTS public."IDX_order_summary_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_shipping_shipping_method_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_return_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_order_id_version";
DROP INDEX IF EXISTS public."IDX_order_shipping_order_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_method_tax_line_shipping_method_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_method_shipping_option_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_method_adjustment_version_shipping_method";
DROP INDEX IF EXISTS public."IDX_order_shipping_method_adjustment_shipping_method_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_item_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_exchange_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_shipping_claim_id";
DROP INDEX IF EXISTS public."IDX_order_shipping_address_id";
DROP INDEX IF EXISTS public."IDX_order_sales_channel_id";
DROP INDEX IF EXISTS public."IDX_order_region_id";
DROP INDEX IF EXISTS public."IDX_order_line_item_variant_id";
DROP INDEX IF EXISTS public."IDX_order_line_item_tax_line_item_id";
DROP INDEX IF EXISTS public."IDX_order_line_item_product_id";
DROP INDEX IF EXISTS public."IDX_order_line_item_adjustment_item_id";
DROP INDEX IF EXISTS public."IDX_order_item_order_id_version";
DROP INDEX IF EXISTS public."IDX_order_item_order_id";
DROP INDEX IF EXISTS public."IDX_order_item_item_id";
DROP INDEX IF EXISTS public."IDX_order_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_is_draft_order";
DROP INDEX IF EXISTS public."IDX_order_id_f42b9949";
DROP INDEX IF EXISTS public."IDX_order_id_-e8d2543e";
DROP INDEX IF EXISTS public."IDX_order_id_-71518339";
DROP INDEX IF EXISTS public."IDX_order_id_-71069c16";
DROP INDEX IF EXISTS public."IDX_order_exchange_return_id";
DROP INDEX IF EXISTS public."IDX_order_exchange_order_id";
DROP INDEX IF EXISTS public."IDX_order_exchange_item_item_id";
DROP INDEX IF EXISTS public."IDX_order_exchange_item_exchange_id";
DROP INDEX IF EXISTS public."IDX_order_exchange_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_exchange_display_id";
DROP INDEX IF EXISTS public."IDX_order_exchange_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_display_id";
DROP INDEX IF EXISTS public."IDX_order_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_customer_id";
DROP INDEX IF EXISTS public."IDX_order_custom_display_id";
DROP INDEX IF EXISTS public."IDX_order_currency_code";
DROP INDEX IF EXISTS public."IDX_order_credit_line_order_id_version";
DROP INDEX IF EXISTS public."IDX_order_credit_line_order_id";
DROP INDEX IF EXISTS public."IDX_order_credit_line_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_claim_return_id";
DROP INDEX IF EXISTS public."IDX_order_claim_order_id";
DROP INDEX IF EXISTS public."IDX_order_claim_item_item_id";
DROP INDEX IF EXISTS public."IDX_order_claim_item_image_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_claim_item_image_claim_item_id";
DROP INDEX IF EXISTS public."IDX_order_claim_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_claim_item_claim_id";
DROP INDEX IF EXISTS public."IDX_order_claim_display_id";
DROP INDEX IF EXISTS public."IDX_order_claim_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_change_version";
DROP INDEX IF EXISTS public."IDX_order_change_status";
DROP INDEX IF EXISTS public."IDX_order_change_return_id";
DROP INDEX IF EXISTS public."IDX_order_change_order_id_version";
DROP INDEX IF EXISTS public."IDX_order_change_order_id";
DROP INDEX IF EXISTS public."IDX_order_change_exchange_id";
DROP INDEX IF EXISTS public."IDX_order_change_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_change_claim_id";
DROP INDEX IF EXISTS public."IDX_order_change_change_type";
DROP INDEX IF EXISTS public."IDX_order_change_action_return_id";
DROP INDEX IF EXISTS public."IDX_order_change_action_ordering";
DROP INDEX IF EXISTS public."IDX_order_change_action_order_id";
DROP INDEX IF EXISTS public."IDX_order_change_action_order_change_id";
DROP INDEX IF EXISTS public."IDX_order_change_action_exchange_id";
DROP INDEX IF EXISTS public."IDX_order_change_action_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_change_action_claim_id";
DROP INDEX IF EXISTS public."IDX_order_billing_address_id";
DROP INDEX IF EXISTS public."IDX_order_address_deleted_at";
DROP INDEX IF EXISTS public."IDX_order_address_customer_id";
DROP INDEX IF EXISTS public."IDX_option_value_option_id_unique";
DROP INDEX IF EXISTS public."IDX_option_product_id_title_unique";
DROP INDEX IF EXISTS public."IDX_notification_receiver_id";
DROP INDEX IF EXISTS public."IDX_notification_provider_id";
DROP INDEX IF EXISTS public."IDX_notification_provider_deleted_at";
DROP INDEX IF EXISTS public."IDX_notification_idempotency_key_unique";
DROP INDEX IF EXISTS public."IDX_notification_deleted_at";
DROP INDEX IF EXISTS public."IDX_line_item_variant_id";
DROP INDEX IF EXISTS public."IDX_line_item_tax_line_tax_rate_id";
DROP INDEX IF EXISTS public."IDX_line_item_product_type_id";
DROP INDEX IF EXISTS public."IDX_line_item_product_id";
DROP INDEX IF EXISTS public."IDX_line_item_adjustment_promotion_id";
DROP INDEX IF EXISTS public."IDX_invite_token";
DROP INDEX IF EXISTS public."IDX_invite_id_-85069d44";
DROP INDEX IF EXISTS public."IDX_invite_email_unique";
DROP INDEX IF EXISTS public."IDX_invite_deleted_at";
DROP INDEX IF EXISTS public."IDX_inventory_level_location_id_inventory_item_id";
DROP INDEX IF EXISTS public."IDX_inventory_level_location_id";
DROP INDEX IF EXISTS public."IDX_inventory_level_inventory_item_id";
DROP INDEX IF EXISTS public."IDX_inventory_level_deleted_at";
DROP INDEX IF EXISTS public."IDX_inventory_item_sku";
DROP INDEX IF EXISTS public."IDX_inventory_item_id_17b4c4e35";
DROP INDEX IF EXISTS public."IDX_inventory_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_image_product_id";
DROP INDEX IF EXISTS public."IDX_image_deleted_at";
DROP INDEX IF EXISTS public."IDX_id_f42b9949";
DROP INDEX IF EXISTS public."IDX_id_ba32fa9c";
DROP INDEX IF EXISTS public."IDX_id_64ff0c4c";
DROP INDEX IF EXISTS public."IDX_id_5cb3a0c0";
DROP INDEX IF EXISTS public."IDX_id_52b23597";
DROP INDEX IF EXISTS public."IDX_id_26d06f470";
DROP INDEX IF EXISTS public."IDX_id_20b454295";
DROP INDEX IF EXISTS public."IDX_id_1c934dab0";
DROP INDEX IF EXISTS public."IDX_id_17b4c4e35";
DROP INDEX IF EXISTS public."IDX_id_17a262437";
DROP INDEX IF EXISTS public."IDX_id_-e8d2543e";
DROP INDEX IF EXISTS public."IDX_id_-e88adb96";
DROP INDEX IF EXISTS public."IDX_id_-a9d4a70b";
DROP INDEX IF EXISTS public."IDX_id_-85069d44";
DROP INDEX IF EXISTS public."IDX_id_-71518339";
DROP INDEX IF EXISTS public."IDX_id_-71069c16";
DROP INDEX IF EXISTS public."IDX_id_-4a39f6c9";
DROP INDEX IF EXISTS public."IDX_id_-31ea43a";
DROP INDEX IF EXISTS public."IDX_id_-1e5992737";
DROP INDEX IF EXISTS public."IDX_id_-1d67bae40";
DROP INDEX IF EXISTS public."IDX_geo_zone_service_zone_id";
DROP INDEX IF EXISTS public."IDX_geo_zone_province_code";
DROP INDEX IF EXISTS public."IDX_geo_zone_deleted_at";
DROP INDEX IF EXISTS public."IDX_geo_zone_country_code";
DROP INDEX IF EXISTS public."IDX_geo_zone_city";
DROP INDEX IF EXISTS public."IDX_fulfillment_shipping_option_id";
DROP INDEX IF EXISTS public."IDX_fulfillment_set_name_unique";
DROP INDEX IF EXISTS public."IDX_fulfillment_set_id_-e88adb96";
DROP INDEX IF EXISTS public."IDX_fulfillment_set_deleted_at";
DROP INDEX IF EXISTS public."IDX_fulfillment_provider_id_-1e5992737";
DROP INDEX IF EXISTS public."IDX_fulfillment_provider_deleted_at";
DROP INDEX IF EXISTS public."IDX_fulfillment_location_id";
DROP INDEX IF EXISTS public."IDX_fulfillment_label_fulfillment_id";
DROP INDEX IF EXISTS public."IDX_fulfillment_label_deleted_at";
DROP INDEX IF EXISTS public."IDX_fulfillment_item_line_item_id";
DROP INDEX IF EXISTS public."IDX_fulfillment_item_inventory_item_id";
DROP INDEX IF EXISTS public."IDX_fulfillment_item_fulfillment_id";
DROP INDEX IF EXISTS public."IDX_fulfillment_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_fulfillment_id_-e8d2543e";
DROP INDEX IF EXISTS public."IDX_fulfillment_id_-31ea43a";
DROP INDEX IF EXISTS public."IDX_fulfillment_deleted_at";
DROP INDEX IF EXISTS public."IDX_fulfillment_address_deleted_at";
DROP INDEX IF EXISTS public."IDX_deleted_at_f42b9949";
DROP INDEX IF EXISTS public."IDX_deleted_at_ba32fa9c";
DROP INDEX IF EXISTS public."IDX_deleted_at_64ff0c4c";
DROP INDEX IF EXISTS public."IDX_deleted_at_5cb3a0c0";
DROP INDEX IF EXISTS public."IDX_deleted_at_52b23597";
DROP INDEX IF EXISTS public."IDX_deleted_at_26d06f470";
DROP INDEX IF EXISTS public."IDX_deleted_at_20b454295";
DROP INDEX IF EXISTS public."IDX_deleted_at_1c934dab0";
DROP INDEX IF EXISTS public."IDX_deleted_at_17b4c4e35";
DROP INDEX IF EXISTS public."IDX_deleted_at_17a262437";
DROP INDEX IF EXISTS public."IDX_deleted_at_-e8d2543e";
DROP INDEX IF EXISTS public."IDX_deleted_at_-e88adb96";
DROP INDEX IF EXISTS public."IDX_deleted_at_-a9d4a70b";
DROP INDEX IF EXISTS public."IDX_deleted_at_-85069d44";
DROP INDEX IF EXISTS public."IDX_deleted_at_-71518339";
DROP INDEX IF EXISTS public."IDX_deleted_at_-71069c16";
DROP INDEX IF EXISTS public."IDX_deleted_at_-4a39f6c9";
DROP INDEX IF EXISTS public."IDX_deleted_at_-31ea43a";
DROP INDEX IF EXISTS public."IDX_deleted_at_-1e5992737";
DROP INDEX IF EXISTS public."IDX_deleted_at_-1d67bae40";
DROP INDEX IF EXISTS public."IDX_customer_id_5cb3a0c0";
DROP INDEX IF EXISTS public."IDX_customer_group_name_unique";
DROP INDEX IF EXISTS public."IDX_customer_group_deleted_at";
DROP INDEX IF EXISTS public."IDX_customer_group_customer_deleted_at";
DROP INDEX IF EXISTS public."IDX_customer_group_customer_customer_id";
DROP INDEX IF EXISTS public."IDX_customer_group_customer_customer_group_id";
DROP INDEX IF EXISTS public."IDX_customer_email_has_account_unique";
DROP INDEX IF EXISTS public."IDX_customer_deleted_at";
DROP INDEX IF EXISTS public."IDX_customer_address_unique_customer_shipping";
DROP INDEX IF EXISTS public."IDX_customer_address_unique_customer_billing";
DROP INDEX IF EXISTS public."IDX_customer_address_deleted_at";
DROP INDEX IF EXISTS public."IDX_customer_address_customer_id";
DROP INDEX IF EXISTS public."IDX_credit_line_deleted_at";
DROP INDEX IF EXISTS public."IDX_credit_line_cart_id";
DROP INDEX IF EXISTS public."IDX_collection_handle_unique";
DROP INDEX IF EXISTS public."IDX_category_handle_unique";
DROP INDEX IF EXISTS public."IDX_cart_shipping_method_tax_line_shipping_method_id";
DROP INDEX IF EXISTS public."IDX_cart_shipping_method_tax_line_deleted_at";
DROP INDEX IF EXISTS public."IDX_cart_shipping_method_deleted_at";
DROP INDEX IF EXISTS public."IDX_cart_shipping_method_cart_id";
DROP INDEX IF EXISTS public."IDX_cart_shipping_method_adjustment_shipping_method_id";
DROP INDEX IF EXISTS public."IDX_cart_shipping_method_adjustment_deleted_at";
DROP INDEX IF EXISTS public."IDX_cart_shipping_address_id";
DROP INDEX IF EXISTS public."IDX_cart_sales_channel_id";
DROP INDEX IF EXISTS public."IDX_cart_region_id";
DROP INDEX IF EXISTS public."IDX_cart_line_item_tax_line_item_id";
DROP INDEX IF EXISTS public."IDX_cart_line_item_tax_line_deleted_at";
DROP INDEX IF EXISTS public."IDX_cart_line_item_deleted_at";
DROP INDEX IF EXISTS public."IDX_cart_line_item_cart_id";
DROP INDEX IF EXISTS public."IDX_cart_line_item_adjustment_item_id";
DROP INDEX IF EXISTS public."IDX_cart_line_item_adjustment_deleted_at";
DROP INDEX IF EXISTS public."IDX_cart_id_-a9d4a70b";
DROP INDEX IF EXISTS public."IDX_cart_id_-71069c16";
DROP INDEX IF EXISTS public."IDX_cart_id_-4a39f6c9";
DROP INDEX IF EXISTS public."IDX_cart_deleted_at";
DROP INDEX IF EXISTS public."IDX_cart_customer_id";
DROP INDEX IF EXISTS public."IDX_cart_currency_code";
DROP INDEX IF EXISTS public."IDX_cart_credit_line_reference_reference_id";
DROP INDEX IF EXISTS public."IDX_cart_billing_address_id";
DROP INDEX IF EXISTS public."IDX_cart_address_deleted_at";
DROP INDEX IF EXISTS public."IDX_capture_payment_id";
DROP INDEX IF EXISTS public."IDX_capture_deleted_at";
DROP INDEX IF EXISTS public."IDX_campaign_budget_type";
DROP INDEX IF EXISTS public."IDX_auth_identity_deleted_at";
DROP INDEX IF EXISTS public."IDX_application_method_type";
DROP INDEX IF EXISTS public."IDX_application_method_target_type";
DROP INDEX IF EXISTS public."IDX_application_method_allocation";
DROP INDEX IF EXISTS public."IDX_api_key_type";
DROP INDEX IF EXISTS public."IDX_api_key_token_unique";
DROP INDEX IF EXISTS public."IDX_api_key_revoked_at";
DROP INDEX IF EXISTS public."IDX_api_key_redacted";
DROP INDEX IF EXISTS public."IDX_api_key_deleted_at";
DROP INDEX IF EXISTS public."IDX_account_holder_provider_id_external_id_unique";
DROP INDEX IF EXISTS public."IDX_account_holder_id_5cb3a0c0";
DROP INDEX IF EXISTS public."IDX_account_holder_deleted_at";
ALTER TABLE IF EXISTS ONLY public.workflow_execution DROP CONSTRAINT IF EXISTS workflow_execution_pkey;
ALTER TABLE IF EXISTS ONLY public.view_configuration DROP CONSTRAINT IF EXISTS view_configuration_pkey;
ALTER TABLE IF EXISTS ONLY public.user_rbac_role DROP CONSTRAINT IF EXISTS user_rbac_role_pkey;
ALTER TABLE IF EXISTS ONLY public.user_preference DROP CONSTRAINT IF EXISTS user_preference_pkey;
ALTER TABLE IF EXISTS ONLY public."user" DROP CONSTRAINT IF EXISTS user_pkey;
ALTER TABLE IF EXISTS ONLY public.tax_region DROP CONSTRAINT IF EXISTS tax_region_pkey;
ALTER TABLE IF EXISTS ONLY public.tax_rate_rule DROP CONSTRAINT IF EXISTS tax_rate_rule_pkey;
ALTER TABLE IF EXISTS ONLY public.tax_rate DROP CONSTRAINT IF EXISTS tax_rate_pkey;
ALTER TABLE IF EXISTS ONLY public.tax_provider DROP CONSTRAINT IF EXISTS tax_provider_pkey;
ALTER TABLE IF EXISTS ONLY public.store DROP CONSTRAINT IF EXISTS store_pkey;
ALTER TABLE IF EXISTS ONLY public.store_locale DROP CONSTRAINT IF EXISTS store_locale_pkey;
ALTER TABLE IF EXISTS ONLY public.store_currency DROP CONSTRAINT IF EXISTS store_currency_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_location DROP CONSTRAINT IF EXISTS stock_location_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_location_address DROP CONSTRAINT IF EXISTS stock_location_address_pkey;
ALTER TABLE IF EXISTS ONLY public.shipping_profile DROP CONSTRAINT IF EXISTS shipping_profile_pkey;
ALTER TABLE IF EXISTS ONLY public.shipping_option_type DROP CONSTRAINT IF EXISTS shipping_option_type_pkey;
ALTER TABLE IF EXISTS ONLY public.shipping_option_rule DROP CONSTRAINT IF EXISTS shipping_option_rule_pkey;
ALTER TABLE IF EXISTS ONLY public.shipping_option_price_set DROP CONSTRAINT IF EXISTS shipping_option_price_set_pkey;
ALTER TABLE IF EXISTS ONLY public.shipping_option DROP CONSTRAINT IF EXISTS shipping_option_pkey;
ALTER TABLE IF EXISTS ONLY public.service_zone DROP CONSTRAINT IF EXISTS service_zone_pkey;
ALTER TABLE IF EXISTS ONLY public.script_migrations DROP CONSTRAINT IF EXISTS script_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.sales_channel_stock_location DROP CONSTRAINT IF EXISTS sales_channel_stock_location_pkey;
ALTER TABLE IF EXISTS ONLY public.sales_channel DROP CONSTRAINT IF EXISTS sales_channel_pkey;
ALTER TABLE IF EXISTS ONLY public.return_reason DROP CONSTRAINT IF EXISTS return_reason_pkey;
ALTER TABLE IF EXISTS ONLY public.return DROP CONSTRAINT IF EXISTS return_pkey;
ALTER TABLE IF EXISTS ONLY public.return_item DROP CONSTRAINT IF EXISTS return_item_pkey;
ALTER TABLE IF EXISTS ONLY public.return_fulfillment DROP CONSTRAINT IF EXISTS return_fulfillment_pkey;
ALTER TABLE IF EXISTS ONLY public.reservation_item DROP CONSTRAINT IF EXISTS reservation_item_pkey;
ALTER TABLE IF EXISTS ONLY public.region DROP CONSTRAINT IF EXISTS region_pkey;
ALTER TABLE IF EXISTS ONLY public.region_payment_provider DROP CONSTRAINT IF EXISTS region_payment_provider_pkey;
ALTER TABLE IF EXISTS ONLY public.region_country DROP CONSTRAINT IF EXISTS region_country_pkey;
ALTER TABLE IF EXISTS ONLY public.refund_reason DROP CONSTRAINT IF EXISTS refund_reason_pkey;
ALTER TABLE IF EXISTS ONLY public.refund DROP CONSTRAINT IF EXISTS refund_pkey;
ALTER TABLE IF EXISTS ONLY public.publishable_api_key_sales_channel DROP CONSTRAINT IF EXISTS publishable_api_key_sales_channel_pkey;
ALTER TABLE IF EXISTS ONLY public.provider_identity DROP CONSTRAINT IF EXISTS provider_identity_pkey;
ALTER TABLE IF EXISTS ONLY public.property_label DROP CONSTRAINT IF EXISTS property_label_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion_rule_value DROP CONSTRAINT IF EXISTS promotion_rule_value_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion_rule DROP CONSTRAINT IF EXISTS promotion_rule_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion_promotion_rule DROP CONSTRAINT IF EXISTS promotion_promotion_rule_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion DROP CONSTRAINT IF EXISTS promotion_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion_campaign DROP CONSTRAINT IF EXISTS promotion_campaign_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion_campaign_budget_usage DROP CONSTRAINT IF EXISTS promotion_campaign_budget_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion_campaign_budget DROP CONSTRAINT IF EXISTS promotion_campaign_budget_pkey;
ALTER TABLE IF EXISTS ONLY public.promotion_application_method DROP CONSTRAINT IF EXISTS promotion_application_method_pkey;
ALTER TABLE IF EXISTS ONLY public.product_variant_product_image DROP CONSTRAINT IF EXISTS product_variant_product_image_pkey;
ALTER TABLE IF EXISTS ONLY public.product_variant_price_set DROP CONSTRAINT IF EXISTS product_variant_price_set_pkey;
ALTER TABLE IF EXISTS ONLY public.product_variant DROP CONSTRAINT IF EXISTS product_variant_pkey;
ALTER TABLE IF EXISTS ONLY public.product_variant_option DROP CONSTRAINT IF EXISTS product_variant_option_pkey;
ALTER TABLE IF EXISTS ONLY public.product_variant_inventory_item DROP CONSTRAINT IF EXISTS product_variant_inventory_item_pkey;
ALTER TABLE IF EXISTS ONLY public.product_type DROP CONSTRAINT IF EXISTS product_type_pkey;
ALTER TABLE IF EXISTS ONLY public.product_tags DROP CONSTRAINT IF EXISTS product_tags_pkey;
ALTER TABLE IF EXISTS ONLY public.product_tag DROP CONSTRAINT IF EXISTS product_tag_pkey;
ALTER TABLE IF EXISTS ONLY public.product_shipping_profile DROP CONSTRAINT IF EXISTS product_shipping_profile_pkey;
ALTER TABLE IF EXISTS ONLY public.product_sales_channel DROP CONSTRAINT IF EXISTS product_sales_channel_pkey;
ALTER TABLE IF EXISTS ONLY public.product DROP CONSTRAINT IF EXISTS product_pkey;
ALTER TABLE IF EXISTS ONLY public.product_option_value DROP CONSTRAINT IF EXISTS product_option_value_pkey;
ALTER TABLE IF EXISTS ONLY public.product_option DROP CONSTRAINT IF EXISTS product_option_pkey;
ALTER TABLE IF EXISTS ONLY public.product_collection DROP CONSTRAINT IF EXISTS product_collection_pkey;
ALTER TABLE IF EXISTS ONLY public.product_category_product DROP CONSTRAINT IF EXISTS product_category_product_pkey;
ALTER TABLE IF EXISTS ONLY public.product_category DROP CONSTRAINT IF EXISTS product_category_pkey;
ALTER TABLE IF EXISTS ONLY public.price_set DROP CONSTRAINT IF EXISTS price_set_pkey;
ALTER TABLE IF EXISTS ONLY public.price_rule DROP CONSTRAINT IF EXISTS price_rule_pkey;
ALTER TABLE IF EXISTS ONLY public.price_preference DROP CONSTRAINT IF EXISTS price_preference_pkey;
ALTER TABLE IF EXISTS ONLY public.price DROP CONSTRAINT IF EXISTS price_pkey;
ALTER TABLE IF EXISTS ONLY public.price_list_rule DROP CONSTRAINT IF EXISTS price_list_rule_pkey;
ALTER TABLE IF EXISTS ONLY public.price_list DROP CONSTRAINT IF EXISTS price_list_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_session DROP CONSTRAINT IF EXISTS payment_session_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_provider DROP CONSTRAINT IF EXISTS payment_provider_pkey;
ALTER TABLE IF EXISTS ONLY public.payment DROP CONSTRAINT IF EXISTS payment_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_collection DROP CONSTRAINT IF EXISTS payment_collection_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_collection_payment_providers DROP CONSTRAINT IF EXISTS payment_collection_payment_providers_pkey;
ALTER TABLE IF EXISTS ONLY public.order_transaction DROP CONSTRAINT IF EXISTS order_transaction_pkey;
ALTER TABLE IF EXISTS ONLY public.order_summary DROP CONSTRAINT IF EXISTS order_summary_pkey;
ALTER TABLE IF EXISTS ONLY public.order_shipping DROP CONSTRAINT IF EXISTS order_shipping_pkey;
ALTER TABLE IF EXISTS ONLY public.order_shipping_method_tax_line DROP CONSTRAINT IF EXISTS order_shipping_method_tax_line_pkey;
ALTER TABLE IF EXISTS ONLY public.order_shipping_method DROP CONSTRAINT IF EXISTS order_shipping_method_pkey;
ALTER TABLE IF EXISTS ONLY public.order_shipping_method_adjustment DROP CONSTRAINT IF EXISTS order_shipping_method_adjustment_pkey;
ALTER TABLE IF EXISTS ONLY public.order_promotion DROP CONSTRAINT IF EXISTS order_promotion_pkey;
ALTER TABLE IF EXISTS ONLY public."order" DROP CONSTRAINT IF EXISTS order_pkey;
ALTER TABLE IF EXISTS ONLY public.order_payment_collection DROP CONSTRAINT IF EXISTS order_payment_collection_pkey;
ALTER TABLE IF EXISTS ONLY public.order_line_item_tax_line DROP CONSTRAINT IF EXISTS order_line_item_tax_line_pkey;
ALTER TABLE IF EXISTS ONLY public.order_line_item DROP CONSTRAINT IF EXISTS order_line_item_pkey;
ALTER TABLE IF EXISTS ONLY public.order_line_item_adjustment DROP CONSTRAINT IF EXISTS order_line_item_adjustment_pkey;
ALTER TABLE IF EXISTS ONLY public.order_item DROP CONSTRAINT IF EXISTS order_item_pkey;
ALTER TABLE IF EXISTS ONLY public.order_fulfillment DROP CONSTRAINT IF EXISTS order_fulfillment_pkey;
ALTER TABLE IF EXISTS ONLY public.order_exchange DROP CONSTRAINT IF EXISTS order_exchange_pkey;
ALTER TABLE IF EXISTS ONLY public.order_exchange_item DROP CONSTRAINT IF EXISTS order_exchange_item_pkey;
ALTER TABLE IF EXISTS ONLY public.order_credit_line DROP CONSTRAINT IF EXISTS order_credit_line_pkey;
ALTER TABLE IF EXISTS ONLY public.order_claim DROP CONSTRAINT IF EXISTS order_claim_pkey;
ALTER TABLE IF EXISTS ONLY public.order_claim_item DROP CONSTRAINT IF EXISTS order_claim_item_pkey;
ALTER TABLE IF EXISTS ONLY public.order_claim_item_image DROP CONSTRAINT IF EXISTS order_claim_item_image_pkey;
ALTER TABLE IF EXISTS ONLY public.order_change DROP CONSTRAINT IF EXISTS order_change_pkey;
ALTER TABLE IF EXISTS ONLY public.order_change_action DROP CONSTRAINT IF EXISTS order_change_action_pkey;
ALTER TABLE IF EXISTS ONLY public.order_cart DROP CONSTRAINT IF EXISTS order_cart_pkey;
ALTER TABLE IF EXISTS ONLY public.order_address DROP CONSTRAINT IF EXISTS order_address_pkey;
ALTER TABLE IF EXISTS ONLY public.notification_provider DROP CONSTRAINT IF EXISTS notification_provider_pkey;
ALTER TABLE IF EXISTS ONLY public.notification DROP CONSTRAINT IF EXISTS notification_pkey;
ALTER TABLE IF EXISTS ONLY public.mikro_orm_migrations DROP CONSTRAINT IF EXISTS mikro_orm_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.location_fulfillment_set DROP CONSTRAINT IF EXISTS location_fulfillment_set_pkey;
ALTER TABLE IF EXISTS ONLY public.location_fulfillment_provider DROP CONSTRAINT IF EXISTS location_fulfillment_provider_pkey;
ALTER TABLE IF EXISTS ONLY public.link_module_migrations DROP CONSTRAINT IF EXISTS link_module_migrations_table_name_key;
ALTER TABLE IF EXISTS ONLY public.link_module_migrations DROP CONSTRAINT IF EXISTS link_module_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.invite_rbac_role DROP CONSTRAINT IF EXISTS invite_rbac_role_pkey;
ALTER TABLE IF EXISTS ONLY public.invite DROP CONSTRAINT IF EXISTS invite_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_level DROP CONSTRAINT IF EXISTS inventory_level_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_item DROP CONSTRAINT IF EXISTS inventory_item_pkey;
ALTER TABLE IF EXISTS ONLY public.image DROP CONSTRAINT IF EXISTS image_pkey;
ALTER TABLE IF EXISTS ONLY public.geo_zone DROP CONSTRAINT IF EXISTS geo_zone_pkey;
ALTER TABLE IF EXISTS ONLY public.fulfillment_set DROP CONSTRAINT IF EXISTS fulfillment_set_pkey;
ALTER TABLE IF EXISTS ONLY public.fulfillment_provider DROP CONSTRAINT IF EXISTS fulfillment_provider_pkey;
ALTER TABLE IF EXISTS ONLY public.fulfillment DROP CONSTRAINT IF EXISTS fulfillment_pkey;
ALTER TABLE IF EXISTS ONLY public.fulfillment_label DROP CONSTRAINT IF EXISTS fulfillment_label_pkey;
ALTER TABLE IF EXISTS ONLY public.fulfillment_item DROP CONSTRAINT IF EXISTS fulfillment_item_pkey;
ALTER TABLE IF EXISTS ONLY public.fulfillment_address DROP CONSTRAINT IF EXISTS fulfillment_address_pkey;
ALTER TABLE IF EXISTS ONLY public.customer DROP CONSTRAINT IF EXISTS customer_pkey;
ALTER TABLE IF EXISTS ONLY public.customer_group DROP CONSTRAINT IF EXISTS customer_group_pkey;
ALTER TABLE IF EXISTS ONLY public.customer_group_customer DROP CONSTRAINT IF EXISTS customer_group_customer_pkey;
ALTER TABLE IF EXISTS ONLY public.customer_address DROP CONSTRAINT IF EXISTS customer_address_pkey;
ALTER TABLE IF EXISTS ONLY public.customer_account_holder DROP CONSTRAINT IF EXISTS customer_account_holder_pkey;
ALTER TABLE IF EXISTS ONLY public.currency DROP CONSTRAINT IF EXISTS currency_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_line DROP CONSTRAINT IF EXISTS credit_line_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_shipping_method_tax_line DROP CONSTRAINT IF EXISTS cart_shipping_method_tax_line_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_shipping_method DROP CONSTRAINT IF EXISTS cart_shipping_method_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_shipping_method_adjustment DROP CONSTRAINT IF EXISTS cart_shipping_method_adjustment_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_promotion DROP CONSTRAINT IF EXISTS cart_promotion_pkey;
ALTER TABLE IF EXISTS ONLY public.cart DROP CONSTRAINT IF EXISTS cart_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_payment_collection DROP CONSTRAINT IF EXISTS cart_payment_collection_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_line_item_tax_line DROP CONSTRAINT IF EXISTS cart_line_item_tax_line_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_line_item DROP CONSTRAINT IF EXISTS cart_line_item_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_line_item_adjustment DROP CONSTRAINT IF EXISTS cart_line_item_adjustment_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_address DROP CONSTRAINT IF EXISTS cart_address_pkey;
ALTER TABLE IF EXISTS ONLY public.capture DROP CONSTRAINT IF EXISTS capture_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_identity DROP CONSTRAINT IF EXISTS auth_identity_pkey;
ALTER TABLE IF EXISTS ONLY public.application_method_target_rules DROP CONSTRAINT IF EXISTS application_method_target_rules_pkey;
ALTER TABLE IF EXISTS ONLY public.application_method_buy_rules DROP CONSTRAINT IF EXISTS application_method_buy_rules_pkey;
ALTER TABLE IF EXISTS ONLY public.api_key DROP CONSTRAINT IF EXISTS api_key_pkey;
ALTER TABLE IF EXISTS ONLY public.account_holder DROP CONSTRAINT IF EXISTS account_holder_pkey;
ALTER TABLE IF EXISTS public.script_migrations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.return ALTER COLUMN display_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.order_exchange ALTER COLUMN display_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.order_claim ALTER COLUMN display_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.order_change_action ALTER COLUMN ordering DROP DEFAULT;
ALTER TABLE IF EXISTS public."order" ALTER COLUMN display_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.mikro_orm_migrations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.link_module_migrations ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.workflow_execution;
DROP TABLE IF EXISTS public.view_configuration;
DROP TABLE IF EXISTS public.user_rbac_role;
DROP TABLE IF EXISTS public.user_preference;
DROP TABLE IF EXISTS public."user";
DROP TABLE IF EXISTS public.tax_region;
DROP TABLE IF EXISTS public.tax_rate_rule;
DROP TABLE IF EXISTS public.tax_rate;
DROP TABLE IF EXISTS public.tax_provider;
DROP TABLE IF EXISTS public.store_locale;
DROP TABLE IF EXISTS public.store_currency;
DROP TABLE IF EXISTS public.store;
DROP TABLE IF EXISTS public.stock_location_address;
DROP TABLE IF EXISTS public.stock_location;
DROP TABLE IF EXISTS public.shipping_profile;
DROP TABLE IF EXISTS public.shipping_option_type;
DROP TABLE IF EXISTS public.shipping_option_rule;
DROP TABLE IF EXISTS public.shipping_option_price_set;
DROP TABLE IF EXISTS public.shipping_option;
DROP TABLE IF EXISTS public.service_zone;
DROP SEQUENCE IF EXISTS public.script_migrations_id_seq;
DROP TABLE IF EXISTS public.script_migrations;
DROP TABLE IF EXISTS public.sales_channel_stock_location;
DROP TABLE IF EXISTS public.sales_channel;
DROP TABLE IF EXISTS public.return_reason;
DROP TABLE IF EXISTS public.return_item;
DROP TABLE IF EXISTS public.return_fulfillment;
DROP SEQUENCE IF EXISTS public.return_display_id_seq;
DROP TABLE IF EXISTS public.return;
DROP TABLE IF EXISTS public.reservation_item;
DROP TABLE IF EXISTS public.region_payment_provider;
DROP TABLE IF EXISTS public.region_country;
DROP TABLE IF EXISTS public.region;
DROP TABLE IF EXISTS public.refund_reason;
DROP TABLE IF EXISTS public.refund;
DROP TABLE IF EXISTS public.publishable_api_key_sales_channel;
DROP TABLE IF EXISTS public.provider_identity;
DROP TABLE IF EXISTS public.property_label;
DROP TABLE IF EXISTS public.promotion_rule_value;
DROP TABLE IF EXISTS public.promotion_rule;
DROP TABLE IF EXISTS public.promotion_promotion_rule;
DROP TABLE IF EXISTS public.promotion_campaign_budget_usage;
DROP TABLE IF EXISTS public.promotion_campaign_budget;
DROP TABLE IF EXISTS public.promotion_campaign;
DROP TABLE IF EXISTS public.promotion_application_method;
DROP TABLE IF EXISTS public.promotion;
DROP TABLE IF EXISTS public.product_variant_product_image;
DROP TABLE IF EXISTS public.product_variant_price_set;
DROP TABLE IF EXISTS public.product_variant_option;
DROP TABLE IF EXISTS public.product_variant_inventory_item;
DROP TABLE IF EXISTS public.product_variant;
DROP TABLE IF EXISTS public.product_type;
DROP TABLE IF EXISTS public.product_tags;
DROP TABLE IF EXISTS public.product_tag;
DROP TABLE IF EXISTS public.product_shipping_profile;
DROP TABLE IF EXISTS public.product_sales_channel;
DROP TABLE IF EXISTS public.product_option_value;
DROP TABLE IF EXISTS public.product_option;
DROP TABLE IF EXISTS public.product_collection;
DROP TABLE IF EXISTS public.product_category_product;
DROP TABLE IF EXISTS public.product_category;
DROP TABLE IF EXISTS public.product;
DROP TABLE IF EXISTS public.price_set;
DROP TABLE IF EXISTS public.price_rule;
DROP TABLE IF EXISTS public.price_preference;
DROP TABLE IF EXISTS public.price_list_rule;
DROP TABLE IF EXISTS public.price_list;
DROP TABLE IF EXISTS public.price;
DROP TABLE IF EXISTS public.payment_session;
DROP TABLE IF EXISTS public.payment_provider;
DROP TABLE IF EXISTS public.payment_collection_payment_providers;
DROP TABLE IF EXISTS public.payment_collection;
DROP TABLE IF EXISTS public.payment;
DROP TABLE IF EXISTS public.order_transaction;
DROP TABLE IF EXISTS public.order_summary;
DROP TABLE IF EXISTS public.order_shipping_method_tax_line;
DROP TABLE IF EXISTS public.order_shipping_method_adjustment;
DROP TABLE IF EXISTS public.order_shipping_method;
DROP TABLE IF EXISTS public.order_shipping;
DROP TABLE IF EXISTS public.order_promotion;
DROP TABLE IF EXISTS public.order_payment_collection;
DROP TABLE IF EXISTS public.order_line_item_tax_line;
DROP TABLE IF EXISTS public.order_line_item_adjustment;
DROP TABLE IF EXISTS public.order_line_item;
DROP TABLE IF EXISTS public.order_item;
DROP TABLE IF EXISTS public.order_fulfillment;
DROP TABLE IF EXISTS public.order_exchange_item;
DROP SEQUENCE IF EXISTS public.order_exchange_display_id_seq;
DROP TABLE IF EXISTS public.order_exchange;
DROP SEQUENCE IF EXISTS public.order_display_id_seq;
DROP TABLE IF EXISTS public.order_credit_line;
DROP TABLE IF EXISTS public.order_claim_item_image;
DROP TABLE IF EXISTS public.order_claim_item;
DROP SEQUENCE IF EXISTS public.order_claim_display_id_seq;
DROP TABLE IF EXISTS public.order_claim;
DROP SEQUENCE IF EXISTS public.order_change_action_ordering_seq;
DROP TABLE IF EXISTS public.order_change_action;
DROP TABLE IF EXISTS public.order_change;
DROP TABLE IF EXISTS public.order_cart;
DROP TABLE IF EXISTS public.order_address;
DROP TABLE IF EXISTS public."order";
DROP TABLE IF EXISTS public.notification_provider;
DROP TABLE IF EXISTS public.notification;
DROP SEQUENCE IF EXISTS public.mikro_orm_migrations_id_seq;
DROP TABLE IF EXISTS public.mikro_orm_migrations;
DROP TABLE IF EXISTS public.location_fulfillment_set;
DROP TABLE IF EXISTS public.location_fulfillment_provider;
DROP SEQUENCE IF EXISTS public.link_module_migrations_id_seq;
DROP TABLE IF EXISTS public.link_module_migrations;
DROP TABLE IF EXISTS public.invite_rbac_role;
DROP TABLE IF EXISTS public.invite;
DROP TABLE IF EXISTS public.inventory_level;
DROP TABLE IF EXISTS public.inventory_item;
DROP TABLE IF EXISTS public.image;
DROP TABLE IF EXISTS public.geo_zone;
DROP TABLE IF EXISTS public.fulfillment_set;
DROP TABLE IF EXISTS public.fulfillment_provider;
DROP TABLE IF EXISTS public.fulfillment_label;
DROP TABLE IF EXISTS public.fulfillment_item;
DROP TABLE IF EXISTS public.fulfillment_address;
DROP TABLE IF EXISTS public.fulfillment;
DROP TABLE IF EXISTS public.customer_group_customer;
DROP TABLE IF EXISTS public.customer_group;
DROP TABLE IF EXISTS public.customer_address;
DROP TABLE IF EXISTS public.customer_account_holder;
DROP TABLE IF EXISTS public.customer;
DROP TABLE IF EXISTS public.currency;
DROP TABLE IF EXISTS public.credit_line;
DROP TABLE IF EXISTS public.cart_shipping_method_tax_line;
DROP TABLE IF EXISTS public.cart_shipping_method_adjustment;
DROP TABLE IF EXISTS public.cart_shipping_method;
DROP TABLE IF EXISTS public.cart_promotion;
DROP TABLE IF EXISTS public.cart_payment_collection;
DROP TABLE IF EXISTS public.cart_line_item_tax_line;
DROP TABLE IF EXISTS public.cart_line_item_adjustment;
DROP TABLE IF EXISTS public.cart_line_item;
DROP TABLE IF EXISTS public.cart_address;
DROP TABLE IF EXISTS public.cart;
DROP TABLE IF EXISTS public.capture;
DROP TABLE IF EXISTS public.auth_identity;
DROP TABLE IF EXISTS public.application_method_target_rules;
DROP TABLE IF EXISTS public.application_method_buy_rules;
DROP TABLE IF EXISTS public.api_key;
DROP TABLE IF EXISTS public.account_holder;
DROP TYPE IF EXISTS public.return_status_enum;
DROP TYPE IF EXISTS public.order_status_enum;
DROP TYPE IF EXISTS public.order_claim_type_enum;
DROP TYPE IF EXISTS public.claim_reason_enum;
--
-- Name: claim_reason_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.claim_reason_enum AS ENUM (
    'missing_item',
    'wrong_item',
    'production_failure',
    'other'
);


--
-- Name: order_claim_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_claim_type_enum AS ENUM (
    'refund',
    'replace'
);


--
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'completed',
    'draft',
    'archived',
    'canceled',
    'requires_action'
);


--
-- Name: return_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.return_status_enum AS ENUM (
    'open',
    'requested',
    'received',
    'partially_received',
    'canceled'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_holder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_holder (
    id text NOT NULL,
    provider_id text NOT NULL,
    external_id text NOT NULL,
    email text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: api_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_key (
    id text NOT NULL,
    token text NOT NULL,
    salt text NOT NULL,
    redacted text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    last_used_at timestamp with time zone,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_by text,
    revoked_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT api_key_type_check CHECK ((type = ANY (ARRAY['publishable'::text, 'secret'::text])))
);


--
-- Name: application_method_buy_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_method_buy_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


--
-- Name: application_method_target_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_method_target_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_identity (
    id text NOT NULL,
    app_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: capture; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capture (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb
);


--
-- Name: cart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart (
    id text NOT NULL,
    region_id text,
    customer_id text,
    sales_channel_id text,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    locale text
);


--
-- Name: cart_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cart_line_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_line_item (
    id text NOT NULL,
    cart_id text NOT NULL,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    quantity integer NOT NULL,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    product_type_id text,
    is_custom_price boolean DEFAULT false NOT NULL,
    is_giftcard boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: cart_line_item_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_adjustment_check CHECK ((amount >= (0)::numeric))
);


--
-- Name: cart_line_item_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text
);


--
-- Name: cart_payment_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_payment_collection (
    cart_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cart_promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_promotion (
    cart_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cart_shipping_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_shipping_method (
    id text NOT NULL,
    cart_id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT cart_shipping_method_check CHECK ((amount >= (0)::numeric))
);


--
-- Name: cart_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


--
-- Name: cart_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


--
-- Name: credit_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_line (
    id text NOT NULL,
    cart_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: currency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency (
    code text NOT NULL,
    symbol text NOT NULL,
    symbol_native text NOT NULL,
    decimal_digits integer DEFAULT 0 NOT NULL,
    rounding numeric DEFAULT 0 NOT NULL,
    raw_rounding jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer (
    id text NOT NULL,
    company_name text,
    first_name text,
    last_name text,
    email text,
    phone text,
    has_account boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text
);


--
-- Name: customer_account_holder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_account_holder (
    customer_id character varying(255) NOT NULL,
    account_holder_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_address (
    id text NOT NULL,
    customer_id text NOT NULL,
    address_name text,
    is_default_shipping boolean DEFAULT false NOT NULL,
    is_default_billing boolean DEFAULT false NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_group (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    created_by text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer_group_customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_group_customer (
    id text NOT NULL,
    customer_id text NOT NULL,
    customer_group_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment (
    id text NOT NULL,
    location_id text NOT NULL,
    packed_at timestamp with time zone,
    shipped_at timestamp with time zone,
    delivered_at timestamp with time zone,
    canceled_at timestamp with time zone,
    data jsonb,
    provider_id text,
    shipping_option_id text,
    metadata jsonb,
    delivery_address_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    marked_shipped_by text,
    created_by text,
    requires_shipping boolean DEFAULT true NOT NULL
);


--
-- Name: fulfillment_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_address (
    id text NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_item (
    id text NOT NULL,
    title text NOT NULL,
    sku text NOT NULL,
    barcode text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    line_item_id text,
    inventory_item_id text,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_label; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_label (
    id text NOT NULL,
    tracking_number text NOT NULL,
    tracking_url text NOT NULL,
    label_url text NOT NULL,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_set (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: geo_zone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.geo_zone (
    id text NOT NULL,
    type text DEFAULT 'country'::text NOT NULL,
    country_code text NOT NULL,
    province_code text,
    city text,
    service_zone_id text NOT NULL,
    postal_expression jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT geo_zone_type_check CHECK ((type = ANY (ARRAY['country'::text, 'province'::text, 'city'::text, 'zip'::text])))
);


--
-- Name: image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image (
    id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    rank integer DEFAULT 0 NOT NULL,
    product_id text NOT NULL
);


--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    sku text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    requires_shipping boolean DEFAULT true NOT NULL,
    description text,
    title text,
    thumbnail text,
    metadata jsonb
);


--
-- Name: inventory_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_level (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    inventory_item_id text NOT NULL,
    location_id text NOT NULL,
    stocked_quantity numeric DEFAULT 0 NOT NULL,
    reserved_quantity numeric DEFAULT 0 NOT NULL,
    incoming_quantity numeric DEFAULT 0 NOT NULL,
    metadata jsonb,
    raw_stocked_quantity jsonb,
    raw_reserved_quantity jsonb,
    raw_incoming_quantity jsonb
);


--
-- Name: invite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invite (
    id text NOT NULL,
    email text NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: invite_rbac_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invite_rbac_role (
    invite_id character varying(255) NOT NULL,
    rbac_role_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: link_module_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_module_migrations (
    id integer NOT NULL,
    table_name character varying(255) NOT NULL,
    link_descriptor jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_module_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_module_migrations_id_seq OWNED BY public.link_module_migrations.id;


--
-- Name: location_fulfillment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_fulfillment_provider (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: location_fulfillment_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_fulfillment_set (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: mikro_orm_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mikro_orm_migrations (
    id integer NOT NULL,
    name character varying(255),
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mikro_orm_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNED BY public.mikro_orm_migrations.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification (
    id text NOT NULL,
    "to" text NOT NULL,
    channel text NOT NULL,
    template text,
    data jsonb,
    trigger_type text,
    resource_id text,
    resource_type text,
    receiver_id text,
    original_notification_id text,
    idempotency_key text,
    external_id text,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'pending'::text NOT NULL,
    "from" text,
    provider_data jsonb,
    CONSTRAINT notification_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'success'::text, 'failure'::text])))
);


--
-- Name: notification_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_provider (
    id text NOT NULL,
    handle text NOT NULL,
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    channels text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."order" (
    id text NOT NULL,
    region_id text,
    display_id integer,
    customer_id text,
    version integer DEFAULT 1 NOT NULL,
    sales_channel_id text,
    status public.order_status_enum DEFAULT 'pending'::public.order_status_enum NOT NULL,
    is_draft_order boolean DEFAULT false NOT NULL,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    no_notification boolean,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    custom_display_id text,
    locale text
);


--
-- Name: order_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_cart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_cart (
    order_id character varying(255) NOT NULL,
    cart_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_change (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    description text,
    status text DEFAULT 'pending'::text NOT NULL,
    internal_note text,
    created_by text,
    requested_by text,
    requested_at timestamp with time zone,
    confirmed_by text,
    confirmed_at timestamp with time zone,
    declined_by text,
    declined_reason text,
    metadata jsonb,
    declined_at timestamp with time zone,
    canceled_by text,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    change_type text,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text,
    carry_over_promotions boolean,
    CONSTRAINT order_change_status_check CHECK ((status = ANY (ARRAY['confirmed'::text, 'declined'::text, 'requested'::text, 'pending'::text, 'canceled'::text])))
);


--
-- Name: order_change_action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_change_action (
    id text NOT NULL,
    order_id text,
    version integer,
    ordering bigint NOT NULL,
    order_change_id text,
    reference text,
    reference_id text,
    action text NOT NULL,
    details jsonb,
    amount numeric,
    raw_amount jsonb,
    internal_note text,
    applied boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_change_action_ordering_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_change_action_ordering_seq OWNED BY public.order_change_action.ordering;


--
-- Name: order_claim; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_claim (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    type public.order_claim_type_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_claim_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_claim_display_id_seq OWNED BY public.order_claim.display_id;


--
-- Name: order_claim_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_claim_item (
    id text NOT NULL,
    claim_id text NOT NULL,
    item_id text NOT NULL,
    is_additional_item boolean DEFAULT false NOT NULL,
    reason public.claim_reason_enum,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_claim_item_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_claim_item_image (
    id text NOT NULL,
    claim_item_id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_credit_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_credit_line (
    id text NOT NULL,
    order_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    version integer DEFAULT 1 NOT NULL
);


--
-- Name: order_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_display_id_seq OWNED BY public."order".display_id;


--
-- Name: order_exchange; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_exchange (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    no_notification boolean,
    allow_backorder boolean DEFAULT false NOT NULL,
    difference_due numeric,
    raw_difference_due jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_exchange_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_exchange_display_id_seq OWNED BY public.order_exchange.display_id;


--
-- Name: order_exchange_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_exchange_item (
    id text NOT NULL,
    exchange_id text NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_fulfillment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_fulfillment (
    order_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_item (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    fulfilled_quantity numeric NOT NULL,
    raw_fulfilled_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    shipped_quantity numeric NOT NULL,
    raw_shipped_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_requested_quantity numeric NOT NULL,
    raw_return_requested_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_received_quantity numeric NOT NULL,
    raw_return_received_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_dismissed_quantity numeric NOT NULL,
    raw_return_dismissed_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    written_off_quantity numeric NOT NULL,
    raw_written_off_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    delivered_quantity numeric DEFAULT 0 NOT NULL,
    raw_delivered_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    unit_price numeric,
    raw_unit_price jsonb,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb
);


--
-- Name: order_line_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_line_item (
    id text NOT NULL,
    totals_id text,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_price boolean DEFAULT false NOT NULL,
    product_type_id text,
    is_giftcard boolean DEFAULT false NOT NULL
);


--
-- Name: order_line_item_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    version integer DEFAULT 1 NOT NULL
);


--
-- Name: order_line_item_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_payment_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_payment_collection (
    order_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_promotion (
    order_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_shipping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    shipping_method_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


--
-- Name: order_shipping_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping_method (
    id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_amount boolean DEFAULT false NOT NULL
);


--
-- Name: order_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone,
    version integer DEFAULT 1 NOT NULL
);


--
-- Name: order_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_summary (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    totals jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_transaction (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    reference text,
    reference_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


--
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    provider_id text NOT NULL,
    data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    captured_at timestamp with time zone,
    canceled_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    payment_session_id text NOT NULL,
    metadata jsonb
);


--
-- Name: payment_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_collection (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    authorized_amount numeric,
    raw_authorized_amount jsonb,
    captured_amount numeric,
    raw_captured_amount jsonb,
    refunded_amount numeric,
    raw_refunded_amount jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    status text DEFAULT 'not_paid'::text NOT NULL,
    metadata jsonb,
    CONSTRAINT payment_collection_status_check CHECK ((status = ANY (ARRAY['not_paid'::text, 'awaiting'::text, 'authorized'::text, 'partially_authorized'::text, 'canceled'::text, 'failed'::text, 'partially_captured'::text, 'completed'::text])))
);


--
-- Name: payment_collection_payment_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_collection_payment_providers (
    payment_collection_id text NOT NULL,
    payment_provider_id text NOT NULL
);


--
-- Name: payment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: payment_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_session (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    context jsonb,
    status text DEFAULT 'pending'::text NOT NULL,
    authorized_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT payment_session_status_check CHECK ((status = ANY (ARRAY['authorized'::text, 'captured'::text, 'pending'::text, 'requires_more'::text, 'error'::text, 'canceled'::text])))
);


--
-- Name: price; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price (
    id text NOT NULL,
    title text,
    price_set_id text NOT NULL,
    currency_code text NOT NULL,
    raw_amount jsonb NOT NULL,
    rules_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    price_list_id text,
    amount numeric NOT NULL,
    min_quantity numeric,
    max_quantity numeric,
    raw_min_quantity jsonb,
    raw_max_quantity jsonb
);


--
-- Name: price_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_list (
    id text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    rules_count integer DEFAULT 0,
    title text NOT NULL,
    description text NOT NULL,
    type text DEFAULT 'sale'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    CONSTRAINT price_list_status_check CHECK ((status = ANY (ARRAY['active'::text, 'draft'::text]))),
    CONSTRAINT price_list_type_check CHECK ((type = ANY (ARRAY['sale'::text, 'override'::text])))
);


--
-- Name: price_list_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_list_rule (
    id text NOT NULL,
    price_list_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    value jsonb,
    attribute text DEFAULT ''::text NOT NULL
);


--
-- Name: price_preference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_preference (
    id text NOT NULL,
    attribute text NOT NULL,
    value text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: price_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_rule (
    id text NOT NULL,
    value text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    price_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    attribute text DEFAULT ''::text NOT NULL,
    operator text DEFAULT 'eq'::text NOT NULL,
    CONSTRAINT price_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text])))
);


--
-- Name: price_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_set (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    subtitle text,
    description text,
    is_giftcard boolean DEFAULT false NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    thumbnail text,
    weight text,
    length text,
    height text,
    width text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    collection_id text,
    type_id text,
    discountable boolean DEFAULT true NOT NULL,
    external_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    CONSTRAINT product_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'proposed'::text, 'published'::text, 'rejected'::text])))
);


--
-- Name: product_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_category (
    id text NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    handle text NOT NULL,
    mpath text NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    is_internal boolean DEFAULT false NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    parent_category_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    external_id text
);


--
-- Name: product_category_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_category_product (
    product_id text NOT NULL,
    product_category_id text NOT NULL
);


--
-- Name: product_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_collection (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    external_id text
);


--
-- Name: product_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_option (
    id text NOT NULL,
    title text NOT NULL,
    product_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_option_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_option_value (
    id text NOT NULL,
    value text NOT NULL,
    option_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_sales_channel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_sales_channel (
    product_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_shipping_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_shipping_profile (
    product_id character varying(255) NOT NULL,
    shipping_profile_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_tag (
    id text NOT NULL,
    value text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    external_id text
);


--
-- Name: product_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_tags (
    product_id text NOT NULL,
    product_tag_id text NOT NULL
);


--
-- Name: product_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_type (
    id text NOT NULL,
    value text NOT NULL,
    metadata json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    external_id text
);


--
-- Name: product_variant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant (
    id text NOT NULL,
    title text NOT NULL,
    sku text,
    barcode text,
    ean text,
    upc text,
    allow_backorder boolean DEFAULT false NOT NULL,
    manage_inventory boolean DEFAULT true NOT NULL,
    hs_code text,
    origin_country text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    metadata jsonb,
    variant_rank integer DEFAULT 0,
    product_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    thumbnail text
);


--
-- Name: product_variant_inventory_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_inventory_item (
    variant_id character varying(255) NOT NULL,
    inventory_item_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    required_quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_variant_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_option (
    variant_id text NOT NULL,
    option_value_id text NOT NULL
);


--
-- Name: product_variant_price_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_price_set (
    variant_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_variant_product_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_product_image (
    id text NOT NULL,
    variant_id text NOT NULL,
    image_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion (
    id text NOT NULL,
    code text NOT NULL,
    campaign_id text,
    is_automatic boolean DEFAULT false NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'draft'::text NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    "limit" integer,
    used integer DEFAULT 0 NOT NULL,
    metadata jsonb,
    CONSTRAINT promotion_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'inactive'::text]))),
    CONSTRAINT promotion_type_check CHECK ((type = ANY (ARRAY['standard'::text, 'buyget'::text])))
);


--
-- Name: promotion_application_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_application_method (
    id text NOT NULL,
    value numeric,
    raw_value jsonb,
    max_quantity integer,
    apply_to_quantity integer,
    buy_rules_min_quantity integer,
    type text NOT NULL,
    target_type text NOT NULL,
    allocation text,
    promotion_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    CONSTRAINT promotion_application_method_allocation_check CHECK ((allocation = ANY (ARRAY['each'::text, 'across'::text, 'once'::text]))),
    CONSTRAINT promotion_application_method_target_type_check CHECK ((target_type = ANY (ARRAY['order'::text, 'shipping_methods'::text, 'items'::text]))),
    CONSTRAINT promotion_application_method_type_check CHECK ((type = ANY (ARRAY['fixed'::text, 'percentage'::text])))
);


--
-- Name: promotion_campaign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_campaign (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    campaign_identifier text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: promotion_campaign_budget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_campaign_budget (
    id text NOT NULL,
    type text NOT NULL,
    campaign_id text NOT NULL,
    "limit" numeric,
    raw_limit jsonb,
    used numeric DEFAULT 0 NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    attribute text,
    CONSTRAINT promotion_campaign_budget_type_check CHECK ((type = ANY (ARRAY['spend'::text, 'usage'::text, 'use_by_attribute'::text, 'spend_by_attribute'::text])))
);


--
-- Name: promotion_campaign_budget_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_campaign_budget_usage (
    id text NOT NULL,
    attribute_value text NOT NULL,
    used numeric DEFAULT 0 NOT NULL,
    budget_id text NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: promotion_promotion_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_promotion_rule (
    promotion_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


--
-- Name: promotion_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_rule (
    id text NOT NULL,
    description text,
    attribute text NOT NULL,
    operator text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT promotion_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text, 'ne'::text, 'in'::text])))
);


--
-- Name: promotion_rule_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_rule_value (
    id text NOT NULL,
    promotion_rule_id text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: property_label; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.property_label (
    id text NOT NULL,
    entity text NOT NULL,
    property text NOT NULL,
    label text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: provider_identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_identity (
    id text NOT NULL,
    entity_id text NOT NULL,
    provider text NOT NULL,
    auth_identity_id text NOT NULL,
    user_metadata jsonb,
    provider_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: publishable_api_key_sales_channel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publishable_api_key_sales_channel (
    publishable_key_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: refund; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb,
    refund_reason_id text,
    note text
);


--
-- Name: refund_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund_reason (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    code text NOT NULL
);


--
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region (
    id text NOT NULL,
    name text NOT NULL,
    currency_code text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    automatic_taxes boolean DEFAULT true NOT NULL
);


--
-- Name: region_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region_country (
    iso_2 text NOT NULL,
    iso_3 text NOT NULL,
    num_code text NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    region_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: region_payment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region_payment_provider (
    region_id character varying(255) NOT NULL,
    payment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: reservation_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reservation_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    line_item_id text,
    location_id text NOT NULL,
    quantity numeric NOT NULL,
    external_id text,
    description text,
    created_by text,
    metadata jsonb,
    inventory_item_id text NOT NULL,
    allow_backorder boolean DEFAULT false,
    raw_quantity jsonb
);


--
-- Name: return; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return (
    id text NOT NULL,
    order_id text NOT NULL,
    claim_id text,
    exchange_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    status public.return_status_enum DEFAULT 'open'::public.return_status_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    received_at timestamp with time zone,
    canceled_at timestamp with time zone,
    location_id text,
    requested_at timestamp with time zone,
    created_by text
);


--
-- Name: return_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.return_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: return_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.return_display_id_seq OWNED BY public.return.display_id;


--
-- Name: return_fulfillment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return_fulfillment (
    return_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: return_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return_item (
    id text NOT NULL,
    return_id text NOT NULL,
    reason_id text,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    received_quantity numeric DEFAULT 0 NOT NULL,
    raw_received_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    damaged_quantity numeric DEFAULT 0 NOT NULL,
    raw_damaged_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL
);


--
-- Name: return_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return_reason (
    id character varying NOT NULL,
    value character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    metadata jsonb,
    parent_return_reason_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: sales_channel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_channel (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    is_disabled boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: sales_channel_stock_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_channel_stock_location (
    sales_channel_id character varying(255) NOT NULL,
    stock_location_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: script_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.script_migrations (
    id integer NOT NULL,
    script_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    finished_at timestamp with time zone
);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.script_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: script_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.script_migrations_id_seq OWNED BY public.script_migrations.id;


--
-- Name: service_zone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_zone (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    fulfillment_set_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: shipping_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option (
    id text NOT NULL,
    name text NOT NULL,
    price_type text DEFAULT 'flat'::text NOT NULL,
    service_zone_id text NOT NULL,
    shipping_profile_id text,
    provider_id text,
    data jsonb,
    metadata jsonb,
    shipping_option_type_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_price_type_check CHECK ((price_type = ANY (ARRAY['calculated'::text, 'flat'::text])))
);


--
-- Name: shipping_option_price_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option_price_set (
    shipping_option_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: shipping_option_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option_rule (
    id text NOT NULL,
    attribute text NOT NULL,
    operator text NOT NULL,
    value jsonb,
    shipping_option_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_rule_operator_check CHECK ((operator = ANY (ARRAY['in'::text, 'eq'::text, 'ne'::text, 'gt'::text, 'gte'::text, 'lt'::text, 'lte'::text, 'nin'::text])))
);


--
-- Name: shipping_option_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option_type (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: shipping_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_profile (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: stock_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_location (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    address_id text,
    metadata jsonb
);


--
-- Name: stock_location_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_location_address (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    address_1 text NOT NULL,
    address_2 text,
    company text,
    city text,
    country_code text NOT NULL,
    phone text,
    province text,
    postal_code text,
    metadata jsonb
);


--
-- Name: store; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store (
    id text NOT NULL,
    name text DEFAULT 'Medusa Store'::text NOT NULL,
    default_sales_channel_id text,
    default_region_id text,
    default_location_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: store_currency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_currency (
    id text NOT NULL,
    currency_code text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: store_locale; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_locale (
    id text NOT NULL,
    locale_code text NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: tax_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: tax_rate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_rate (
    id text NOT NULL,
    rate real,
    code text NOT NULL,
    name text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_combinable boolean DEFAULT false NOT NULL,
    tax_region_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


--
-- Name: tax_rate_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_rate_rule (
    id text NOT NULL,
    tax_rate_id text NOT NULL,
    reference_id text NOT NULL,
    reference text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


--
-- Name: tax_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_region (
    id text NOT NULL,
    provider_id text,
    country_code text NOT NULL,
    province_code text,
    parent_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone,
    CONSTRAINT "CK_tax_region_country_top_level" CHECK (((parent_id IS NULL) OR (province_code IS NOT NULL))),
    CONSTRAINT "CK_tax_region_provider_top_level" CHECK (((parent_id IS NULL) OR (provider_id IS NULL)))
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id text NOT NULL,
    first_name text,
    last_name text,
    email text NOT NULL,
    avatar_url text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: user_preference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_preference (
    id text NOT NULL,
    user_id text NOT NULL,
    key text NOT NULL,
    value jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: user_rbac_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_rbac_role (
    user_id character varying(255) NOT NULL,
    rbac_role_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: view_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.view_configuration (
    id text NOT NULL,
    entity text NOT NULL,
    name text,
    user_id text,
    is_system_default boolean DEFAULT false NOT NULL,
    configuration jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: workflow_execution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_execution (
    id character varying NOT NULL,
    workflow_id character varying NOT NULL,
    transaction_id character varying NOT NULL,
    execution jsonb,
    context jsonb,
    state character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone,
    retention_time integer,
    run_id text DEFAULT '01KQPHSBB3GBZZA5A2A20Q9X8S'::text NOT NULL
);


--
-- Name: link_module_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_module_migrations ALTER COLUMN id SET DEFAULT nextval('public.link_module_migrations_id_seq'::regclass);


--
-- Name: mikro_orm_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mikro_orm_migrations ALTER COLUMN id SET DEFAULT nextval('public.mikro_orm_migrations_id_seq'::regclass);


--
-- Name: order display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order" ALTER COLUMN display_id SET DEFAULT nextval('public.order_display_id_seq'::regclass);


--
-- Name: order_change_action ordering; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change_action ALTER COLUMN ordering SET DEFAULT nextval('public.order_change_action_ordering_seq'::regclass);


--
-- Name: order_claim display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim ALTER COLUMN display_id SET DEFAULT nextval('public.order_claim_display_id_seq'::regclass);


--
-- Name: order_exchange display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_exchange ALTER COLUMN display_id SET DEFAULT nextval('public.order_exchange_display_id_seq'::regclass);


--
-- Name: return display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return ALTER COLUMN display_id SET DEFAULT nextval('public.return_display_id_seq'::regclass);


--
-- Name: script_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script_migrations ALTER COLUMN id SET DEFAULT nextval('public.script_migrations_id_seq'::regclass);


--
-- Data for Name: account_holder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account_holder (id, provider_id, external_id, email, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.api_key (id, token, salt, redacted, title, type, last_used_at, created_by, created_at, revoked_by, revoked_at, updated_at, deleted_at) FROM stdin;
apk_01KQPHSEH4N8PF3KH85WCXVKSN	pk_ce37ffe6e5d8f2d4caa1edda5afc4a5a15b89d76b08d1d918daebc206e7bc111		pk_ce3***111	Default Publishable API Key	publishable	\N		2026-05-03 09:12:56.1+00	\N	\N	2026-05-03 09:12:56.1+00	\N
apk_01KQPJ7FZ41ZTCA7ZTJQG0TPS7	pk_837964090c2a2f45dae85f8c4850afde7974713017f0293bc97285289211d302		pk_837***302	Bayblaze Storefront Publishable Key	publishable	\N		2026-05-03 09:20:36.324+00	\N	\N	2026-05-03 09:20:36.324+00	\N
\.


--
-- Data for Name: application_method_buy_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_method_buy_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: application_method_target_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_method_target_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_identity (id, app_metadata, created_at, updated_at, deleted_at) FROM stdin;
authid_01KQQGQTDHRQQ1E49BJW2QXXQK	{"user_id": "user_01KQQGQTAXWETD7Q63QR2Z0EYE"}	2026-05-03 18:13:48.593+00	2026-05-03 18:13:48.603+00	\N
\.


--
-- Data for Name: capture; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.capture (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata) FROM stdin;
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart (id, region_id, customer_id, sales_channel_id, email, currency_code, shipping_address_id, billing_address_id, metadata, created_at, updated_at, deleted_at, completed_at, locale) FROM stdin;
\.


--
-- Data for Name: cart_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_line_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_line_item (id, cart_id, title, subtitle, thumbnail, quantity, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, product_type_id, is_custom_price, is_giftcard) FROM stdin;
\.


--
-- Data for Name: cart_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, item_id, is_tax_inclusive) FROM stdin;
\.


--
-- Data for Name: cart_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_line_item_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_payment_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_payment_collection (cart_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_promotion (cart_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_shipping_method (id, cart_id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_shipping_method_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: credit_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_line (id, cart_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.currency (code, symbol, symbol_native, decimal_digits, rounding, raw_rounding, name, created_at, updated_at, deleted_at) FROM stdin;
usd	$	$	2	0	{"value": "0", "precision": 20}	US Dollar	2026-05-03 09:12:55.093+00	2026-05-03 09:12:55.093+00	\N
cad	CA$	$	2	0	{"value": "0", "precision": 20}	Canadian Dollar	2026-05-03 09:12:55.093+00	2026-05-03 09:12:55.093+00	\N
eur	€	€	2	0	{"value": "0", "precision": 20}	Euro	2026-05-03 09:12:55.093+00	2026-05-03 09:12:55.093+00	\N
aed	AED	د.إ.‏	2	0	{"value": "0", "precision": 20}	United Arab Emirates Dirham	2026-05-03 09:12:55.093+00	2026-05-03 09:12:55.093+00	\N
afn	Af	؋	0	0	{"value": "0", "precision": 20}	Afghan Afghani	2026-05-03 09:12:55.093+00	2026-05-03 09:12:55.093+00	\N
all	ALL	Lek	0	0	{"value": "0", "precision": 20}	Albanian Lek	2026-05-03 09:12:55.093+00	2026-05-03 09:12:55.093+00	\N
amd	AMD	դր.	0	0	{"value": "0", "precision": 20}	Armenian Dram	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
ars	AR$	$	2	0	{"value": "0", "precision": 20}	Argentine Peso	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
aud	AU$	$	2	0	{"value": "0", "precision": 20}	Australian Dollar	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
azn	man.	ман.	2	0	{"value": "0", "precision": 20}	Azerbaijani Manat	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bam	KM	KM	2	0	{"value": "0", "precision": 20}	Bosnia-Herzegovina Convertible Mark	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bdt	Tk	৳	2	0	{"value": "0", "precision": 20}	Bangladeshi Taka	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bgn	BGN	лв.	2	0	{"value": "0", "precision": 20}	Bulgarian Lev	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bhd	BD	د.ب.‏	3	0	{"value": "0", "precision": 20}	Bahraini Dinar	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bif	FBu	FBu	0	0	{"value": "0", "precision": 20}	Burundian Franc	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bnd	BN$	$	2	0	{"value": "0", "precision": 20}	Brunei Dollar	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bob	Bs	Bs	2	0	{"value": "0", "precision": 20}	Bolivian Boliviano	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
brl	R$	R$	2	0	{"value": "0", "precision": 20}	Brazilian Real	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bwp	BWP	P	2	0	{"value": "0", "precision": 20}	Botswanan Pula	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
byn	Br	руб.	2	0	{"value": "0", "precision": 20}	Belarusian Ruble	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
bzd	BZ$	$	2	0	{"value": "0", "precision": 20}	Belize Dollar	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
cdf	CDF	FrCD	2	0	{"value": "0", "precision": 20}	Congolese Franc	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
chf	CHF	CHF	2	0.05	{"value": "0.05", "precision": 20}	Swiss Franc	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
clp	CL$	$	0	0	{"value": "0", "precision": 20}	Chilean Peso	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
cny	CN¥	CN¥	2	0	{"value": "0", "precision": 20}	Chinese Yuan	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
cop	CO$	$	0	0	{"value": "0", "precision": 20}	Colombian Peso	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
crc	₡	₡	0	0	{"value": "0", "precision": 20}	Costa Rican Colón	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
cve	CV$	CV$	2	0	{"value": "0", "precision": 20}	Cape Verdean Escudo	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
czk	Kč	Kč	2	0	{"value": "0", "precision": 20}	Czech Republic Koruna	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
djf	Fdj	Fdj	0	0	{"value": "0", "precision": 20}	Djiboutian Franc	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
dkk	Dkr	kr	2	0	{"value": "0", "precision": 20}	Danish Krone	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
dop	RD$	RD$	2	0	{"value": "0", "precision": 20}	Dominican Peso	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
dzd	DA	د.ج.‏	2	0	{"value": "0", "precision": 20}	Algerian Dinar	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
eek	Ekr	kr	2	0	{"value": "0", "precision": 20}	Estonian Kroon	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
egp	EGP	ج.م.‏	2	0	{"value": "0", "precision": 20}	Egyptian Pound	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
ern	Nfk	Nfk	2	0	{"value": "0", "precision": 20}	Eritrean Nakfa	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
etb	Br	Br	2	0	{"value": "0", "precision": 20}	Ethiopian Birr	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
gbp	£	£	2	0	{"value": "0", "precision": 20}	British Pound Sterling	2026-05-03 09:12:55.094+00	2026-05-03 09:12:55.094+00	\N
gel	GEL	GEL	2	0	{"value": "0", "precision": 20}	Georgian Lari	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
ghs	GH₵	GH₵	2	0	{"value": "0", "precision": 20}	Ghanaian Cedi	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
gnf	FG	FG	0	0	{"value": "0", "precision": 20}	Guinean Franc	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
gtq	GTQ	Q	2	0	{"value": "0", "precision": 20}	Guatemalan Quetzal	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
hkd	HK$	$	2	0	{"value": "0", "precision": 20}	Hong Kong Dollar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
hnl	HNL	L	2	0	{"value": "0", "precision": 20}	Honduran Lempira	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
hrk	kn	kn	2	0	{"value": "0", "precision": 20}	Croatian Kuna	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
huf	Ft	Ft	0	0	{"value": "0", "precision": 20}	Hungarian Forint	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
idr	Rp	Rp	0	0	{"value": "0", "precision": 20}	Indonesian Rupiah	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
ils	₪	₪	2	0	{"value": "0", "precision": 20}	Israeli New Sheqel	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
inr	Rs	₹	2	0	{"value": "0", "precision": 20}	Indian Rupee	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
iqd	IQD	د.ع.‏	0	0	{"value": "0", "precision": 20}	Iraqi Dinar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
irr	IRR	﷼	0	0	{"value": "0", "precision": 20}	Iranian Rial	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
isk	Ikr	kr	0	0	{"value": "0", "precision": 20}	Icelandic Króna	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
jmd	J$	$	2	0	{"value": "0", "precision": 20}	Jamaican Dollar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
jod	JD	د.أ.‏	3	0	{"value": "0", "precision": 20}	Jordanian Dinar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
jpy	¥	￥	0	0	{"value": "0", "precision": 20}	Japanese Yen	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
kes	Ksh	Ksh	2	0	{"value": "0", "precision": 20}	Kenyan Shilling	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
khr	KHR	៛	2	0	{"value": "0", "precision": 20}	Cambodian Riel	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
kmf	CF	FC	0	0	{"value": "0", "precision": 20}	Comorian Franc	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
krw	₩	₩	0	0	{"value": "0", "precision": 20}	South Korean Won	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
kwd	KD	د.ك.‏	3	0	{"value": "0", "precision": 20}	Kuwaiti Dinar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
kzt	KZT	тңг.	2	0	{"value": "0", "precision": 20}	Kazakhstani Tenge	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
lbp	LB£	ل.ل.‏	0	0	{"value": "0", "precision": 20}	Lebanese Pound	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
lkr	SLRs	SL Re	2	0	{"value": "0", "precision": 20}	Sri Lankan Rupee	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
ltl	Lt	Lt	2	0	{"value": "0", "precision": 20}	Lithuanian Litas	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
lvl	Ls	Ls	2	0	{"value": "0", "precision": 20}	Latvian Lats	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
lyd	LD	د.ل.‏	3	0	{"value": "0", "precision": 20}	Libyan Dinar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mad	MAD	د.م.‏	2	0	{"value": "0", "precision": 20}	Moroccan Dirham	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mdl	MDL	MDL	2	0	{"value": "0", "precision": 20}	Moldovan Leu	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mga	MGA	MGA	0	0	{"value": "0", "precision": 20}	Malagasy Ariary	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mkd	MKD	MKD	2	0	{"value": "0", "precision": 20}	Macedonian Denar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mmk	MMK	K	0	0	{"value": "0", "precision": 20}	Myanma Kyat	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mnt	MNT	₮	0	0	{"value": "0", "precision": 20}	Mongolian Tugrig	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mop	MOP$	MOP$	2	0	{"value": "0", "precision": 20}	Macanese Pataca	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mur	MURs	MURs	0	0	{"value": "0", "precision": 20}	Mauritian Rupee	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mwk	K	K	2	0	{"value": "0", "precision": 20}	Malawian Kwacha	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mxn	MX$	$	2	0	{"value": "0", "precision": 20}	Mexican Peso	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
myr	RM	RM	2	0	{"value": "0", "precision": 20}	Malaysian Ringgit	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
mzn	MTn	MTn	2	0	{"value": "0", "precision": 20}	Mozambican Metical	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
nad	N$	N$	2	0	{"value": "0", "precision": 20}	Namibian Dollar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
ngn	₦	₦	2	0	{"value": "0", "precision": 20}	Nigerian Naira	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
nio	C$	C$	2	0	{"value": "0", "precision": 20}	Nicaraguan Córdoba	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
nok	Nkr	kr	2	0	{"value": "0", "precision": 20}	Norwegian Krone	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
npr	NPRs	नेरू	2	0	{"value": "0", "precision": 20}	Nepalese Rupee	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
nzd	NZ$	$	2	0	{"value": "0", "precision": 20}	New Zealand Dollar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
omr	OMR	ر.ع.‏	3	0	{"value": "0", "precision": 20}	Omani Rial	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
pab	B/.	B/.	2	0	{"value": "0", "precision": 20}	Panamanian Balboa	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
pen	S/.	S/.	2	0	{"value": "0", "precision": 20}	Peruvian Nuevo Sol	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
php	₱	₱	2	0	{"value": "0", "precision": 20}	Philippine Peso	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
pkr	PKRs	₨	0	0	{"value": "0", "precision": 20}	Pakistani Rupee	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
pln	zł	zł	2	0	{"value": "0", "precision": 20}	Polish Zloty	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
pyg	₲	₲	0	0	{"value": "0", "precision": 20}	Paraguayan Guarani	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
qar	QR	ر.ق.‏	2	0	{"value": "0", "precision": 20}	Qatari Rial	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
ron	RON	RON	2	0	{"value": "0", "precision": 20}	Romanian Leu	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
rsd	din.	дин.	0	0	{"value": "0", "precision": 20}	Serbian Dinar	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
rub	RUB	₽.	2	0	{"value": "0", "precision": 20}	Russian Ruble	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.095+00	\N
rwf	RWF	FR	0	0	{"value": "0", "precision": 20}	Rwandan Franc	2026-05-03 09:12:55.095+00	2026-05-03 09:12:55.096+00	\N
sar	SR	ر.س.‏	2	0	{"value": "0", "precision": 20}	Saudi Riyal	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
sdg	SDG	SDG	2	0	{"value": "0", "precision": 20}	Sudanese Pound	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
sek	Skr	kr	2	0	{"value": "0", "precision": 20}	Swedish Krona	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
sgd	S$	$	2	0	{"value": "0", "precision": 20}	Singapore Dollar	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
sos	Ssh	Ssh	0	0	{"value": "0", "precision": 20}	Somali Shilling	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
syp	SY£	ل.س.‏	0	0	{"value": "0", "precision": 20}	Syrian Pound	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
thb	฿	฿	2	0	{"value": "0", "precision": 20}	Thai Baht	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
tnd	DT	د.ت.‏	3	0	{"value": "0", "precision": 20}	Tunisian Dinar	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
top	T$	T$	2	0	{"value": "0", "precision": 20}	Tongan Paʻanga	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
tjs	TJS	с.	2	0	{"value": "0", "precision": 20}	Tajikistani Somoni	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
try	₺	₺	2	0	{"value": "0", "precision": 20}	Turkish Lira	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
ttd	TT$	$	2	0	{"value": "0", "precision": 20}	Trinidad and Tobago Dollar	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
twd	NT$	NT$	2	0	{"value": "0", "precision": 20}	New Taiwan Dollar	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
tzs	TSh	TSh	0	0	{"value": "0", "precision": 20}	Tanzanian Shilling	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
uah	₴	₴	2	0	{"value": "0", "precision": 20}	Ukrainian Hryvnia	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
ugx	USh	USh	0	0	{"value": "0", "precision": 20}	Ugandan Shilling	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
uyu	$U	$	2	0	{"value": "0", "precision": 20}	Uruguayan Peso	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
uzs	UZS	UZS	0	0	{"value": "0", "precision": 20}	Uzbekistan Som	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
vef	Bs.F.	Bs.F.	2	0	{"value": "0", "precision": 20}	Venezuelan Bolívar	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
vnd	₫	₫	0	0	{"value": "0", "precision": 20}	Vietnamese Dong	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
xaf	FCFA	FCFA	0	0	{"value": "0", "precision": 20}	CFA Franc BEAC	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
xof	CFA	CFA	0	0	{"value": "0", "precision": 20}	CFA Franc BCEAO	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
xpf	₣	₣	0	0	{"value": "0", "precision": 20}	CFP Franc	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
yer	YR	ر.ي.‏	0	0	{"value": "0", "precision": 20}	Yemeni Rial	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
zar	R	R	2	0	{"value": "0", "precision": 20}	South African Rand	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
zmk	ZK	ZK	0	0	{"value": "0", "precision": 20}	Zambian Kwacha	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
zwl	ZWL$	ZWL$	0	0	{"value": "0", "precision": 20}	Zimbabwean Dollar	2026-05-03 09:12:55.096+00	2026-05-03 09:12:55.096+00	\N
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer (id, company_name, first_name, last_name, email, phone, has_account, metadata, created_at, updated_at, deleted_at, created_by) FROM stdin;
\.


--
-- Data for Name: customer_account_holder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_account_holder (customer_id, account_holder_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_address (id, customer_id, address_name, is_default_shipping, is_default_billing, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_group (id, name, metadata, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group_customer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_group_customer (id, customer_id, customer_group_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment (id, location_id, packed_at, shipped_at, delivered_at, canceled_at, data, provider_id, shipping_option_id, metadata, delivery_address_id, created_at, updated_at, deleted_at, marked_shipped_by, created_by, requires_shipping) FROM stdin;
\.


--
-- Data for Name: fulfillment_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_address (id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_item (id, title, sku, barcode, quantity, raw_quantity, line_item_id, inventory_item_id, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_label; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_label (id, tracking_number, tracking_url, label_url, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
manual_manual	t	2026-05-03 09:12:55.152+00	2026-05-03 09:12:55.152+00	\N
\.


--
-- Data for Name: fulfillment_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_set (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuset_01KQPHSEMM1F56YMCQYP82RARJ	European Warehouse delivery	shipping	\N	2026-05-03 09:12:56.212+00	2026-05-07 03:52:28.396+00	2026-05-07 03:52:28.395+00
fuset_01KR0944SBGKK3GSMA8Q0HFY5B	Iyad Eltifi shipping	shipping	\N	2026-05-07 03:53:53.708+00	2026-05-07 03:53:53.708+00	\N
\.


--
-- Data for Name: geo_zone; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.geo_zone (id, type, country_code, province_code, city, service_zone_id, postal_expression, metadata, created_at, updated_at, deleted_at) FROM stdin;
fgz_01KQPHSEMKP4KNY05YT5MWZ3TM	country	gb	\N	\N	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	\N	\N	2026-05-03 09:12:56.212+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
fgz_01KQPHSEMKSTQSFJDWPG44ZDQR	country	de	\N	\N	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	\N	\N	2026-05-03 09:12:56.213+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
fgz_01KQPHSEMK3MBWZY4T0KX645FF	country	dk	\N	\N	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	\N	\N	2026-05-03 09:12:56.213+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
fgz_01KQPHSEMK6G77N4SN1WZMZNM8	country	se	\N	\N	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	\N	\N	2026-05-03 09:12:56.213+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
fgz_01KQPHSEMKFATFCHXJFFQFGQ75	country	fr	\N	\N	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	\N	\N	2026-05-03 09:12:56.213+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
fgz_01KQPHSEMKSK2B0FBCHZ0NT49S	country	es	\N	\N	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	\N	\N	2026-05-03 09:12:56.213+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
fgz_01KQPHSEMKTTKW2285J6XB00E5	country	it	\N	\N	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	\N	\N	2026-05-03 09:12:56.213+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
fgz_01KR0959J863QPJQ3BJ9Y2RFWQ	country	us	\N	\N	serzo_01KR0959J9HRS439K810RP978Y	\N	\N	2026-05-07 03:54:31.371+00	2026-05-07 03:54:31.371+00	\N
\.


--
-- Data for Name: image; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.image (id, url, metadata, created_at, updated_at, deleted_at, rank, product_id) FROM stdin;
img_01KQPHSERFESCP4ST1B6X6MZ8B	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.619+00	2026-05-03 18:16:54.606+00	0	prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9
img_01KQPHSERFMTQ7MF4N2DS3DCH0	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-back.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.619+00	2026-05-03 18:16:54.606+00	1	prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9
img_01KQPHSERD1NCCF4DXWVAQWBM6	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC
img_01KQPHSERD07H8N17G4PRAFQ5Q	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-back.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	1	prod_01KQPHSERAFDQSTVMMVTCQJ5PC
img_01KQPHSERDA7EM4AXBRS751FFB	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-front.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	2	prod_01KQPHSERAFDQSTVMMVTCQJ5PC
img_01KQPHSERDH3V967664F287070	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-back.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	3	prod_01KQPHSERAFDQSTVMMVTCQJ5PC
img_01KQPHSERFF27MP9MHPTT72M1D	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.293+00	2026-05-03 18:17:02.283+00	0	prod_01KQPHSERBDBQMVHYR2D3TKKJY
img_01KQPHSERFCWKNGBQ8A7RNHE0V	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-back.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.293+00	2026-05-03 18:17:02.283+00	1	prod_01KQPHSERBDBQMVHYR2D3TKKJY
img_01KQPHSERGPRSE0MTDWHXVG3YT	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.195+00	2026-05-03 18:17:06.185+00	0	prod_01KQPHSERBX5WG7WWAYKMHKVE8
img_01KQPHSERGRSTEW3BAFJEBCXY0	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-back.png	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.195+00	2026-05-03 18:17:06.185+00	1	prod_01KQPHSERBX5WG7WWAYKMHKVE8
img_01KQPJ7G1GD3B4VVGQG5WZCC9S	https://bayblaze.net/wp-content/uploads/2026/03/wave.png	\N	2026-05-03 09:20:36.402+00	2026-05-03 18:17:14.668+00	2026-05-03 18:17:14.659+00	0	prod_01KQPJ7G1DRW1S8AMV6AP72KDB
img_01KR020EQ37PPV958PSXFFYAD8	images/raz-vue-pre-filled-replacement-pod-50000-puffs/00.jpg	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	0	prod_01KR020EPM5X42055YHXD2VB8M
img_01KR020EQ3R9CKXJ435ZC0KKDS	images/raz-vue-pre-filled-replacement-pod-50000-puffs/01.jpg	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	1	prod_01KR020EPM5X42055YHXD2VB8M
img_01KR020EQ6P4Z6BMTBVJE305VQ	images/raz-vue-kit-disposable-50000-puffs/00.jpg	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8
img_01KR020EQ7SRA39WWTZ5XZ3CEE	images/raz-vue-kit-disposable-50000-puffs/01.jpg	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	1	prod_01KR020EPNHR59Q1C2FZ7S4QH8
img_01KR020EQ8W30QD602E5BYWY4J	images/raz-rx-disposable-50000-puffs/00.jpg	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00	0	prod_01KR020EPNMAV2M74GW005XGRD
img_01KR020EQ9ECG0DKY51H7YSN03	images/raz-rx-disposable-50000-puffs/01.png	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00	1	prod_01KR020EPNMAV2M74GW005XGRD
img_01KR020EQEJFG4KN829PFVZHR1	images/raz-ltx-zero-nicotine-disposable-25000-puffs/00.jpg	\N	2026-05-07 01:49:32.786+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00	0	prod_01KR020EPNN8K97EZMCJFTC5R2
img_01KR020EQEFTZGEHDVQ95WHRPD	images/raz-ltx-zero-nicotine-disposable-25000-puffs/01.jpg	\N	2026-05-07 01:49:32.786+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00	1	prod_01KR020EPNN8K97EZMCJFTC5R2
img_01KR020EQCY4D8P8VPS49AM9ZV	images/geekvape-raz-dc25000-disposable-25000-puffs/00.jpg	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:28:02.994+00	2026-05-07 02:28:02.986+00	0	prod_01KR020EPNY1RZMM5WJNCQ66HB
img_01KR020EQCS9R5ZJZCVXKRK0HZ	images/geekvape-raz-dc25000-disposable-25000-puffs/01.jpg	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:28:02.994+00	2026-05-07 02:28:02.986+00	1	prod_01KR020EPNY1RZMM5WJNCQ66HB
img_01KQPJ7G1GDF85PCAR9KYCPE2Q	https://bayblaze.net/wp-content/uploads/2026/03/LMMTK35K.png	\N	2026-05-03 09:20:36.402+00	2026-05-07 02:52:47.914+00	2026-05-07 02:52:47.892+00	0	prod_01KQPJ7G1DGCS8J83FXCGA00S8
img_01KQPJ7G1FBPJ1Z68KT2WNBMX6	https://bayblaze.net/wp-content/uploads/2026/03/raz-ltx-25000-gush-edition-blue-raz-gush.png	\N	2026-05-03 09:20:36.402+00	2026-05-07 02:53:04.702+00	2026-05-07 02:53:04.682+00	0	prod_01KQPJ7G1DHT5KBQDV18K81HN8
img_01KR06N1Y5JN8V776694Z506HJ	http://localhost:9000/static/1778123442057-raz-tn900-main.jpg	\N	2026-05-07 03:10:42.119+00	2026-05-07 03:10:42.119+00	\N	0	prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ
vtizfe	http://localhost:9000/static/1778123636300-raz-tn9000-alt1.jpg	\N	2026-05-07 03:13:56.46+00	2026-05-07 03:13:56.46+00	\N	1	prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ
img_01KR21MGDXA6VAZQDQFRGK2JMF	http://localhost:9000/static/1778185290122-LMMTK35K.png	\N	2026-05-07 20:21:30.176+00	2026-05-07 20:21:30.176+00	\N	0	prod_01KR21MGDTXDF9B55TKB39PM04
img_01KR21MGDXJ33W8Q3ESZ2KG952	http://localhost:9000/static/1778185290125-LMMTK35K-alt.png	\N	2026-05-07 20:21:30.176+00	2026-05-07 20:21:30.176+00	\N	1	prod_01KR21MGDTXDF9B55TKB39PM04
img_01KR21MGDXP16YFWFMTS76EKCG	http://localhost:9000/static/1778185290124-LMMT35KT-alt2.png	\N	2026-05-07 20:21:30.176+00	2026-05-07 20:21:30.176+00	\N	2	prod_01KR21MGDTXDF9B55TKB39PM04
img_01KR26GH31YPQWZ984CJ4Q7W18	http://localhost:9000/static/1778190402520-Geek-Bar-Pulse-15000-Disposable.png	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N	0	prod_01KR26GH2MNKJP9X74ZMA3NPQV
img_01KR26GH37QK3XRD9C2VX24HA1	http://localhost:9000/static/1778190402520-Geek-Bar-Pulse-15000-Disposable-Miami-Mint.png	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N	1	prod_01KR26GH2MNKJP9X74ZMA3NPQV
img_01KR26GH37252JFAF1AWJYTESD	http://localhost:9000/static/1778190402520-Geek-Bar-Pulse-15000-Disposable-Blue-Razz-Ice.png	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N	2	prod_01KR26GH2MNKJP9X74ZMA3NPQV
img_01KR26GH37143X38PJE2EFAP87	http://localhost:9000/static/1778190402522-Geek-Bar-Pulse-15000-Disposable-berry-bliss.png	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N	3	prod_01KR26GH2MNKJP9X74ZMA3NPQV
img_01KR26GH37XX7BV8ZP5QME3ST5	http://localhost:9000/static/1778190402522-Geek-Bar-Pulse-15000-Disposable-blueberry-watermelon.png	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N	4	prod_01KR26GH2MNKJP9X74ZMA3NPQV
img_01KR2AAAW03XR5HRVWCRSWD0YR	http://localhost:9000/static/1778194393878-RAZ-LTX-Disposable-Vape-25K.png	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N	0	prod_01KR2AAAVPRZ3VG53QESA2AWGN
img_01KR2AAAW0VRNXPZ0HGQYSARKN	http://localhost:9000/static/1778194393882-miami-mint-raz-ltx-25000.jpg	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N	1	prod_01KR2AAAVPRZ3VG53QESA2AWGN
img_01KR2AAAW021WAQAXP49J6Q6AC	http://localhost:9000/static/1778194393884-blue-raz-ice-raz-ltx-25000.jpg	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N	2	prod_01KR2AAAVPRZ3VG53QESA2AWGN
img_01KR2AAAW0XZJCKJ2DSKB2T2D5	http://localhost:9000/static/1778194393884-RAZ-LTX-25K_Sour-Apple-Ice-800x800__94556.jpg	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N	3	prod_01KR2AAAVPRZ3VG53QESA2AWGN
img_01KR2AAAW0685Z1RR7Q9CZTQY2	http://localhost:9000/static/1778194393884-RAZ-LTX-25K_Mango-Loco-800x800__03352.jpg	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N	4	prod_01KR2AAAVPRZ3VG53QESA2AWGN
img_01KR2CNPMB7V1NFPRQHCYR62F0	http://localhost:9000/static/1778196863594-raw-king-cones-3pk.jpg	\N	2026-05-07 23:34:23.631+00	2026-05-07 23:34:23.631+00	\N	0	prod_01KR2CNPM96BND9CVPP0R3GJWD
img_01KR2CNPMCBTVG3WSJM3VNBYVR	http://localhost:9000/static/1778196863596-raw-king-cones-3pk-alt.jpg	\N	2026-05-07 23:34:23.631+00	2026-05-07 23:34:23.631+00	\N	1	prod_01KR2CNPM96BND9CVPP0R3GJWD
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_item (id, created_at, updated_at, deleted_at, sku, origin_country, hs_code, mid_code, material, weight, length, height, width, requires_shipping, description, title, thumbnail, metadata) FROM stdin;
iitem_01KQPJ7G3T6SMTKBMT6E9K88J8	2026-05-03 09:20:36.475+00	2026-05-07 02:52:47.844+00	2026-05-07 02:52:47.841+00	LOST-MARY-MT35000-TURBO	\N	\N	\N	\N	\N	\N	\N	\N	t	Default	Default	\N	\N
iitem_01KQPJ7G3TM1X2BWNQQMWBSFJ6	2026-05-03 09:20:36.474+00	2026-05-07 02:53:04.648+00	2026-05-07 02:53:04.647+00	RAZ-LTX-25000-BLUE-RAZ-GUSH	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue Raz Gush	Blue Raz Gush	\N	\N
iitem_01KQPHSEV9FP21RZAFKT5WDN4F	2026-05-03 09:12:56.426+00	2026-05-03 18:16:54.55+00	2026-05-03 18:16:54.548+00	SWEATSHIRT-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KQPHSEV9SQ2VNMPE9KA02HTZ	2026-05-03 09:12:56.426+00	2026-05-03 18:16:54.566+00	2026-05-03 18:16:54.548+00	SWEATSHIRT-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KQPHSEV9334Y8ESSHA7SXXRD	2026-05-03 09:12:56.426+00	2026-05-03 18:16:54.573+00	2026-05-03 18:16:54.548+00	SWEATSHIRT-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KQPHSEV9RQMXKVFG92C216BK	2026-05-03 09:12:56.426+00	2026-05-03 18:16:54.579+00	2026-05-03 18:16:54.548+00	SWEATSHIRT-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KQPHSEV8A0Z8NS94H30H8N8V	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.583+00	2026-05-03 18:16:58.583+00	SHIRT-L-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	L / Black	L / Black	\N	\N
iitem_01KQPHSEV87C9WEWRNW04EDFWY	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.589+00	2026-05-03 18:16:58.583+00	SHIRT-L-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	L / White	L / White	\N	\N
iitem_01KQPHSEV8GT1Q2TXX78H1CYX2	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.595+00	2026-05-03 18:16:58.583+00	SHIRT-M-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	M / Black	M / Black	\N	\N
iitem_01KQPHSEV8RWRZ5HV2BTRX70VE	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.6+00	2026-05-03 18:16:58.583+00	SHIRT-M-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	M / White	M / White	\N	\N
iitem_01KQPHSEV834S9D3TH81TRV6MC	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.606+00	2026-05-03 18:16:58.583+00	SHIRT-S-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	S / Black	S / Black	\N	\N
iitem_01KQPHSEV8R9EF3J2GVN13TGHK	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.611+00	2026-05-03 18:16:58.583+00	SHIRT-S-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	S / White	S / White	\N	\N
iitem_01KQPHSEV8BCTFY003EWYA5V6Q	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.616+00	2026-05-03 18:16:58.583+00	SHIRT-XL-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / Black	XL / Black	\N	\N
iitem_01KQPHSEV829RNGRSJCDZYKNVN	2026-05-03 09:12:56.426+00	2026-05-03 18:16:58.621+00	2026-05-03 18:16:58.583+00	SHIRT-XL-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / White	XL / White	\N	\N
iitem_01KQPHSEV90GMZFB3PM4AAYBNS	2026-05-03 09:12:56.426+00	2026-05-03 18:17:02.244+00	2026-05-03 18:17:02.244+00	SWEATPANTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KQPHSEV9J6F34RQSKHCTGCMN	2026-05-03 09:12:56.426+00	2026-05-03 18:17:02.252+00	2026-05-03 18:17:02.244+00	SWEATPANTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KQPHSEV9MSD6Z98ENR76MDV8	2026-05-03 09:12:56.426+00	2026-05-03 18:17:02.257+00	2026-05-03 18:17:02.244+00	SWEATPANTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KQPHSEV9Z2WA4T8ANZZKG7RB	2026-05-03 09:12:56.426+00	2026-05-03 18:17:02.262+00	2026-05-03 18:17:02.244+00	SWEATPANTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KQPHSEV9YKKA19T4RG6XD8J3	2026-05-03 09:12:56.426+00	2026-05-03 18:17:06.145+00	2026-05-03 18:17:06.145+00	SHORTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KQPHSEV965XEBDNEJBX4YWGA	2026-05-03 09:12:56.426+00	2026-05-03 18:17:06.152+00	2026-05-03 18:17:06.145+00	SHORTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KQPHSEV9NP942J4PA63DXQWG	2026-05-03 09:12:56.426+00	2026-05-03 18:17:06.158+00	2026-05-03 18:17:06.145+00	SHORTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KQPHSEVADJ0C65PKQTQDBMS8	2026-05-03 09:12:56.426+00	2026-05-03 18:17:06.163+00	2026-05-03 18:17:06.145+00	SHORTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KQPJ7G3TWE98KMNXAC7J84DW	2026-05-03 09:20:36.475+00	2026-05-03 18:17:14.643+00	2026-05-03 18:17:14.643+00	WAVE	\N	\N	\N	\N	\N	\N	\N	\N	t	Default	Default	\N	\N
iitem_01KR020EX3KMSJ7R8F2D2FEJGE	2026-05-07 01:49:32.972+00	2026-05-07 02:27:45.202+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-miami-mint	\N	\N	\N	\N	\N	\N	\N	\N	t	Miami Mint	Miami Mint	\N	\N
iitem_01KR020EX4BPRBR1XA58PZSGJB	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.217+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-polar-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Polar Ice	Polar Ice	\N	\N
iitem_01KR020EX49FZ81Q3RGCPSWQWA	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.22+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-triple-berry-lime	\N	\N	\N	\N	\N	\N	\N	\N	t	Triple Berry Lime	Triple Berry Lime	\N	\N
iitem_01KR020EX40PGJ082H30QXAJNC	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.222+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-blue-raz-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue Raz Ice	Blue Raz Ice	\N	\N
iitem_01KR020EX41E2ACVWSM7XR6K06	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.227+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-hawaiian-punch	\N	\N	\N	\N	\N	\N	\N	\N	t	Hawaiian Punch	Hawaiian Punch	\N	\N
iitem_01KR020EX4KM97E2A21MBFDHF9	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.23+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-pineapple-mtn-dew	\N	\N	\N	\N	\N	\N	\N	\N	t	Pineapple MTN Dew	Pineapple MTN Dew	\N	\N
iitem_01KR020EX4VCWFYVA27GSC3SHR	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.234+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-sour-apple-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Sour Apple Ice	Sour Apple Ice	\N	\N
iitem_01KR020EX4WNJ7C2JGR6FZ138A	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.237+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-strawberry-blast	\N	\N	\N	\N	\N	\N	\N	\N	t	Strawberry Blast	Strawberry Blast	\N	\N
iitem_01KR020EX554WR4DFPH5EZ019C	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.239+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-watermelon-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Watermelon Ice	Watermelon Ice	\N	\N
iitem_01KR020EX5NW10C17RCH4SWJ7Q	2026-05-07 01:49:32.973+00	2026-05-07 02:27:45.242+00	2026-05-07 02:27:45.198+00	gvp-raz-vue-50k-pod-1pk-white-gummy	\N	\N	\N	\N	\N	\N	\N	\N	t	White Gummy	White Gummy	\N	\N
iitem_01KR020EX5TAX9Q75VA96YD2ST	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.123+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-blue-raz-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue Raz Ice	Blue Raz Ice	\N	\N
iitem_01KR020EX5KFSBJ2SSAG466BXX	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.13+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-hawaiian-punch	\N	\N	\N	\N	\N	\N	\N	\N	t	Hawaiian Punch	Hawaiian Punch	\N	\N
iitem_01KR020EX562KK8CPGHDYQHN44	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.132+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-miami-mint	\N	\N	\N	\N	\N	\N	\N	\N	t	Miami Mint	Miami Mint	\N	\N
iitem_01KR020EX5ZTR4NACK24QNW40Z	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.134+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-pineapple-mtn-dew	\N	\N	\N	\N	\N	\N	\N	\N	t	Pineapple MTN Dew	Pineapple MTN Dew	\N	\N
iitem_01KR020EX5VQY74D48QCAWMN21	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.137+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-polar-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Polar Ice	Polar Ice	\N	\N
iitem_01KR020EX5SV8MY6AP6SVJRCD8	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.141+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-sour-apple-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Sour Apple Ice	Sour Apple Ice	\N	\N
iitem_01KR020EX69GYYKR3Z3D7XRPEE	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.143+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-strawberry-blast	\N	\N	\N	\N	\N	\N	\N	\N	t	Strawberry Blast	Strawberry Blast	\N	\N
iitem_01KR020EX6J44SDNPBDJSXP0T9	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.147+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-triple-berry-lime	\N	\N	\N	\N	\N	\N	\N	\N	t	Triple Berry Lime	Triple Berry Lime	\N	\N
iitem_01KR020EX6T7K2VE5P73QR7NQH	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.151+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-watermelon-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Watermelon Ice	Watermelon Ice	\N	\N
iitem_01KR020EX6ZPY24SYD191VXMKW	2026-05-07 01:49:32.973+00	2026-05-07 02:27:50.154+00	2026-05-07 02:27:50.123+00	gvp-raz-vue-kit-50k-disp-white-gummy	\N	\N	\N	\N	\N	\N	\N	\N	t	White Gummy	White Gummy	\N	\N
iitem_01KR020EX6QWCFSMEP8YYBSSPB	2026-05-07 01:49:32.973+00	2026-05-07 02:27:53.805+00	2026-05-07 02:27:53.805+00	gvp-raz-rx-50k-disp-code-blue	\N	\N	\N	\N	\N	\N	\N	\N	t	Code Blue	Code Blue	\N	\N
iitem_01KR020EX69M0Z7688GPDKYHKG	2026-05-07 01:49:32.973+00	2026-05-07 02:27:53.814+00	2026-05-07 02:27:53.805+00	gvp-raz-rx-50k-disp-code-green	\N	\N	\N	\N	\N	\N	\N	\N	t	Code Green	Code Green	\N	\N
iitem_01KR020EX6QYWKD99X6AAHKCNP	2026-05-07 01:49:32.973+00	2026-05-07 02:27:53.819+00	2026-05-07 02:27:53.805+00	gvp-raz-rx-50k-disp-code-pink	\N	\N	\N	\N	\N	\N	\N	\N	t	Code Pink	Code Pink	\N	\N
iitem_01KR020EX6RD20NC1WN7W3HNSE	2026-05-07 01:49:32.973+00	2026-05-07 02:27:53.822+00	2026-05-07 02:27:53.805+00	gvp-raz-rx-50k-disp-code-red	\N	\N	\N	\N	\N	\N	\N	\N	t	Code Red	Code Red	\N	\N
iitem_01KR020EX6YCRYT4CG1XA68GV5	2026-05-07 01:49:32.973+00	2026-05-07 02:27:53.825+00	2026-05-07 02:27:53.805+00	gvp-raz-rx-50k-disp-code-white	\N	\N	\N	\N	\N	\N	\N	\N	t	Code White	Code White	\N	\N
iitem_01KR020EX6N6WRZV3MKBMCDCJ8	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.011+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-bangin-sour-berries	\N	\N	\N	\N	\N	\N	\N	\N	t	Bangin Sour Berries	Bangin Sour Berries	\N	\N
iitem_01KR020EX6NZXCMPVZ9QQG8DKJ	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.022+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-black-cherry-peach	\N	\N	\N	\N	\N	\N	\N	\N	t	Black Cherry Peach	Black Cherry Peach	\N	\N
iitem_01KR020EX7CDNTFBDAJ1XYVM3J	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.028+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-blue-raz-gush	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue Raz Gush - Gush Edition	Blue Raz Gush - Gush Edition	\N	\N
iitem_01KR020EX7NKBDA8FYVGC4G1DY	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.036+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-blue-razz-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue Razz Ice	Blue Razz Ice	\N	\N
iitem_01KR020EX71VPCA5F2HEHJYTK2	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.041+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-blueberry-punch	\N	\N	\N	\N	\N	\N	\N	\N	t	Blueberry Punch - Punch Edition	Blueberry Punch - Punch Edition	\N	\N
iitem_01KR020EX7X273NEX19GNVSB5Q	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.045+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-blueberry-watermelon	\N	\N	\N	\N	\N	\N	\N	\N	t	Blueberry Watermelon	Blueberry Watermelon	\N	\N
iitem_01KR020EX7T2Z3JZNWES7C7Z70	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.053+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-cherry-strapple	\N	\N	\N	\N	\N	\N	\N	\N	t	Cherry Strapple	Cherry Strapple	\N	\N
iitem_01KR020EX7M3RZYN9Y7NSS0HG4	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.064+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-clear	\N	\N	\N	\N	\N	\N	\N	\N	t	Clear	Clear	\N	\N
iitem_01KR020EX7R04DZCPDBXAJF2V1	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.07+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-clear-diamond	\N	\N	\N	\N	\N	\N	\N	\N	t	Clear Diamond	Clear Diamond	\N	\N
iitem_01KR020EX7RXYVRAD74YYKD39B	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.078+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-clear-sapphire	\N	\N	\N	\N	\N	\N	\N	\N	t	Clear Sapphire	Clear Sapphire	\N	\N
iitem_01KR020EX78P0M73HXFGAFN5HH	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.088+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-fire-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Fire & Ice	Fire & Ice	\N	\N
iitem_01KR020EX7DXA31D5X9Z72BHV6	2026-05-07 01:49:32.973+00	2026-05-07 02:27:48.094+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-frozen-banana	\N	\N	\N	\N	\N	\N	\N	\N	t	Frozen Banana	Frozen Banana	\N	\N
iitem_01KR020EX74SEDC8MN69SK8E02	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.1+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-frozen-cherry-apple	\N	\N	\N	\N	\N	\N	\N	\N	t	Frozen Cherry Apple	Frozen Cherry Apple	\N	\N
iitem_01KR020EX8V5A2HCE2QX4SNS1V	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.116+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-frozen-dragonfruit-lemon	\N	\N	\N	\N	\N	\N	\N	\N	t	Frozen Dragonfruit Lemon	Frozen Dragonfruit Lemon	\N	\N
iitem_01KR020EX87H55YN4G86ZZJF2W	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.123+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-frozen-juicy-strawberry	\N	\N	\N	\N	\N	\N	\N	\N	t	Frozen Juicy Strawberry	Frozen Juicy Strawberry	\N	\N
iitem_01KR020EX847D28S7D8D2B6X5J	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.13+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-frozen-raspberry-watermelon	\N	\N	\N	\N	\N	\N	\N	\N	t	Frozen Raspberry Watermelon	Frozen Raspberry Watermelon	\N	\N
iitem_01KR020EX8B76Q6J5382C5GZJ5	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.136+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-georgia-peach	\N	\N	\N	\N	\N	\N	\N	\N	t	Georgia Peach	Georgia Peach	\N	\N
iitem_01KR020EX86MVAH148R9DESJNQ	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.143+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-hawaiian-punch	\N	\N	\N	\N	\N	\N	\N	\N	t	Hawaiian Punch - Punch Edition	Hawaiian Punch - Punch Edition	\N	\N
iitem_01KR020EX8W1WBDC6AQZFA4PNR	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.149+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-iced-blue-dragon	\N	\N	\N	\N	\N	\N	\N	\N	t	Iced Blue Dragon	Iced Blue Dragon	\N	\N
iitem_01KR020EX8W0ZA15G6CDB3C9BC	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.154+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-miami-mint	\N	\N	\N	\N	\N	\N	\N	\N	t	Miami Mint	Miami Mint	\N	\N
iitem_01KR020EX9GAE3G8GJCSFDHJW5	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.16+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-new-york-mint	\N	\N	\N	\N	\N	\N	\N	\N	t	New York Mint	New York Mint	\N	\N
iitem_01KR020EX90437JTA23EE72T41	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.164+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-night-crawler	\N	\N	\N	\N	\N	\N	\N	\N	t	Night Crawler	Night Crawler	\N	\N
iitem_01KR020EX9E83M4A0CTRBNT1AM	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.17+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-orange-pineapple-punch	\N	\N	\N	\N	\N	\N	\N	\N	t	Orange Pineapple Punch - Punch Edition	Orange Pineapple Punch - Punch Edition	\N	\N
iitem_01KR020EX9JQJ3SZ8XYNHG4VTK	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.174+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-pink-lemonade-minty-os	\N	\N	\N	\N	\N	\N	\N	\N	t	Pink Lemonade Minty O's	Pink Lemonade Minty O's	\N	\N
iitem_01KR020EX9KGCEHYE9VPHWXP1V	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.181+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-rainbow-rain	\N	\N	\N	\N	\N	\N	\N	\N	t	Rainbow Rain	Rainbow Rain	\N	\N
iitem_01KR020EXA2Q9AP4877N7H88KR	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.188+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-raspberry-limeade	\N	\N	\N	\N	\N	\N	\N	\N	t	Raspberry Limeade	Raspberry Limeade	\N	\N
iitem_01KR020EXA3QBYB535FA2MZ1P9	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.193+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-razzle-dazzle	\N	\N	\N	\N	\N	\N	\N	\N	t	Razzle Dazzle	Razzle Dazzle	\N	\N
iitem_01KR020EXAYJNHWCBN23RCA8AS	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.198+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-sour-apple-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Sour Apple Ice	Sour Apple Ice	\N	\N
iitem_01KR020EXAFE7MTZW5B11SA7JC	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.202+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-sour-raspberry-punch	\N	\N	\N	\N	\N	\N	\N	\N	t	Sour Raspberry Punch - Punch Edition	Sour Raspberry Punch - Punch Edition	\N	\N
iitem_01KR020EXA4KZC29JV5CW5K96Z	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.207+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-strawberry-burst	\N	\N	\N	\N	\N	\N	\N	\N	t	Strawberry Burst	Strawberry Burst	\N	\N
iitem_01KR020EXAK1V99BEGEAFZQF4M	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.212+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-strawberry-kiwi-pear	\N	\N	\N	\N	\N	\N	\N	\N	t	Strawberry Kiwi Pear	Strawberry Kiwi Pear	\N	\N
iitem_01KR020EXA828TAVSPGDH43S4W	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.218+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-strawberry-orange-tang	\N	\N	\N	\N	\N	\N	\N	\N	t	Strawberry Orange Tang	Strawberry Orange Tang	\N	\N
iitem_01KR020EXAXZQYQQR45Q3P6ETE	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.223+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-strawberry-peach-gush	\N	\N	\N	\N	\N	\N	\N	\N	t	Strawberry Peach Gush - Gush Edition	Strawberry Peach Gush - Gush Edition	\N	\N
iitem_01KR020EXAY3CSWNY2TJ6B4DE6	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.23+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-triple-berry-gush	\N	\N	\N	\N	\N	\N	\N	\N	t	Triple Berry Gush - Gush Edition	Triple Berry Gush - Gush Edition	\N	\N
iitem_01KR020EXBNJAVMHTGX3J6MD1D	2026-05-07 01:49:32.974+00	2026-05-07 02:28:00.085+00	2026-05-07 02:28:00.085+00	gvp-raz-ltx-25k-0nic-disp-1pk-bangin-sour-berries	\N	\N	\N	\N	\N	\N	\N	\N	t	Bangin Sour Berries	Bangin Sour Berries	\N	\N
iitem_01KR020EXBMZ5RS0221NTY4BG9	2026-05-07 01:49:32.974+00	2026-05-07 02:28:00.088+00	2026-05-07 02:28:00.085+00	gvp-raz-ltx-25k-0nic-disp-1pk-blueberry-watermelon	\N	\N	\N	\N	\N	\N	\N	\N	t	Blueberry Watermelon	Blueberry Watermelon	\N	\N
iitem_01KR020EXBEE109PHV5AZ14V4B	2026-05-07 01:49:32.974+00	2026-05-07 02:28:02.967+00	2026-05-07 02:28:02.967+00	gvp-raz-dc25000-disp-1pk-mango-loco	\N	\N	\N	\N	\N	\N	\N	\N	t	Mango Loco	Mango Loco	\N	\N
iitem_01KR020EXB2H31P5Q75MT32YQX	2026-05-07 01:49:32.974+00	2026-05-07 02:28:02.971+00	2026-05-07 02:28:02.967+00	gvp-raz-dc25000-disp-1pk-pink-lemonade-minty-os	\N	\N	\N	\N	\N	\N	\N	\N	t	Pink Lemonade Minty O's	Pink Lemonade Minty O's	\N	\N
iitem_01KR020EXAR50N3JZ11TD2R90W	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.238+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-triple-berry-punch	\N	\N	\N	\N	\N	\N	\N	\N	t	Triple Berry Punch - Punch Edition	Triple Berry Punch - Punch Edition	\N	\N
iitem_01KR020EXBBEFNVC1AZT2GRK1F	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.246+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-tropical-gush	\N	\N	\N	\N	\N	\N	\N	\N	t	Tropical Gush - Gush Edition	Tropical Gush - Gush Edition	\N	\N
iitem_01KR020EXB7EDH0RJMVPG26Q9M	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.253+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-watermelon-ice	\N	\N	\N	\N	\N	\N	\N	\N	t	Watermelon Ice	Watermelon Ice	\N	\N
iitem_01KR020EXBZ6GFS2GGR3JZWFJG	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.258+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-white-grape-gush	\N	\N	\N	\N	\N	\N	\N	\N	t	White Grape Gush - Gush Edition	White Grape Gush - Gush Edition	\N	\N
iitem_01KR020EXBFJEGNZZ55ZMPZA6P	2026-05-07 01:49:32.974+00	2026-05-07 02:27:48.263+00	2026-05-07 02:27:48.011+00	gvp-raz-ltx-25k-disp-1pk-wintergreen	\N	\N	\N	\N	\N	\N	\N	\N	t	Wintergreen	Wintergreen	\N	\N
iitem_01KR020EXB7XM4X8S8CRSVQHF7	2026-05-07 01:49:32.974+00	2026-05-07 02:28:00.091+00	2026-05-07 02:28:00.085+00	gvp-raz-ltx-25k-0nic-disp-1pk-new-york-mint	\N	\N	\N	\N	\N	\N	\N	\N	t	New York Mint	New York Mint	\N	\N
iitem_01KR020EXBN1WM7CM1YM5F0RQ7	2026-05-07 01:49:32.974+00	2026-05-07 02:28:00.093+00	2026-05-07 02:28:00.085+00	gvp-raz-ltx-25k-0nic-disp-1pk-razzle-dazzle	\N	\N	\N	\N	\N	\N	\N	\N	t	Razzle Dazzle	Razzle Dazzle	\N	\N
iitem_01KR020EXC447FS5KPEEKBJ594	2026-05-07 01:49:32.974+00	2026-05-07 02:28:00.096+00	2026-05-07 02:28:00.085+00	gvp-raz-ltx-25k-0nic-disp-1pk-strawberry-burst	\N	\N	\N	\N	\N	\N	\N	\N	t	Strawberry Burst	Strawberry Burst	\N	\N
\.


--
-- Data for Name: inventory_level; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_level (id, created_at, updated_at, deleted_at, inventory_item_id, location_id, stocked_quantity, reserved_quantity, incoming_quantity, metadata, raw_stocked_quantity, raw_reserved_quantity, raw_incoming_quantity) FROM stdin;
ilev_01KQPHSEYER0EB3TV5CFWTW0WN	2026-05-03 09:12:56.527+00	2026-05-03 18:16:54.565+00	2026-05-03 18:16:54.548+00	iitem_01KQPHSEV9FP21RZAFKT5WDN4F	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYEBEV224PNVH0T5VMB	2026-05-03 09:12:56.527+00	2026-05-03 18:16:54.573+00	2026-05-03 18:16:54.548+00	iitem_01KQPHSEV9SQ2VNMPE9KA02HTZ	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYD2YRY492ZH0XJ52AG	2026-05-03 09:12:56.527+00	2026-05-03 18:16:54.579+00	2026-05-03 18:16:54.548+00	iitem_01KQPHSEV9334Y8ESSHA7SXXRD	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYE9KW5N9XE3GV15TTZ	2026-05-03 09:12:56.527+00	2026-05-03 18:16:54.584+00	2026-05-03 18:16:54.548+00	iitem_01KQPHSEV9RQMXKVFG92C216BK	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDHDGKKFBEGWVBQQNV	2026-05-03 09:12:56.527+00	2026-05-03 18:16:58.589+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV8A0Z8NS94H30H8N8V	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDDP592MZ1QFBM3QWZ	2026-05-03 09:12:56.527+00	2026-05-03 18:16:58.595+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV87C9WEWRNW04EDFWY	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDFZK9VR172YAK5P12	2026-05-03 09:12:56.527+00	2026-05-03 18:16:58.6+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV8GT1Q2TXX78H1CYX2	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYD1E7GEM6B46BVGS0M	2026-05-03 09:12:56.527+00	2026-05-03 18:16:58.605+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV8RWRZ5HV2BTRX70VE	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDG48A0WQ4H7FAB8XB	2026-05-03 09:12:56.526+00	2026-05-03 18:16:58.611+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV834S9D3TH81TRV6MC	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDJ2TRXF1CVXTCGV8D	2026-05-03 09:12:56.527+00	2026-05-03 18:16:58.616+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV8R9EF3J2GVN13TGHK	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDZ3E5WCFZHJPGZNFW	2026-05-03 09:12:56.527+00	2026-05-03 18:17:02.252+00	2026-05-03 18:17:02.244+00	iitem_01KQPHSEV90GMZFB3PM4AAYBNS	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYETYNERSZEV1VSKEQS	2026-05-03 09:12:56.527+00	2026-05-03 18:17:02.257+00	2026-05-03 18:17:02.244+00	iitem_01KQPHSEV9J6F34RQSKHCTGCMN	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYEKCZ577XN270MDN4G	2026-05-03 09:12:56.527+00	2026-05-03 18:17:02.262+00	2026-05-03 18:17:02.244+00	iitem_01KQPHSEV9MSD6Z98ENR76MDV8	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYEQ2NYAGKTS4T6CSK0	2026-05-03 09:12:56.527+00	2026-05-03 18:17:02.267+00	2026-05-03 18:17:02.244+00	iitem_01KQPHSEV9Z2WA4T8ANZZKG7RB	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYEEHRKNFADND7R3S5E	2026-05-03 09:12:56.527+00	2026-05-03 18:17:06.152+00	2026-05-03 18:17:06.145+00	iitem_01KQPHSEV9YKKA19T4RG6XD8J3	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYED4W95XG0FRJ6K9SK	2026-05-03 09:12:56.527+00	2026-05-03 18:17:06.158+00	2026-05-03 18:17:06.145+00	iitem_01KQPHSEV965XEBDNEJBX4YWGA	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYEV1BA5WDGCADST5A7	2026-05-03 09:12:56.527+00	2026-05-03 18:17:06.162+00	2026-05-03 18:17:06.145+00	iitem_01KQPHSEV9NP942J4PA63DXQWG	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYE8JQK08235605GKN6	2026-05-03 09:12:56.527+00	2026-05-03 18:17:06.167+00	2026-05-03 18:17:06.145+00	iitem_01KQPHSEVADJ0C65PKQTQDBMS8	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDQCM2MKS8C1493SK8	2026-05-03 09:12:56.527+00	2026-05-03 18:16:58.621+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV8BCTFY003EWYA5V6Q	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KQPHSEYDV9WJSASEV9QE20NK	2026-05-03 09:12:56.526+00	2026-05-03 18:16:58.628+00	2026-05-03 18:16:58.583+00	iitem_01KQPHSEV829RNGRSJCDZYKNVN	sloc_01KQPHSEM3J9F24P547ZY11ENJ	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
\.


--
-- Data for Name: invite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invite (id, email, accepted, token, expires_at, metadata, created_at, updated_at, deleted_at) FROM stdin;
invite_01KQPHSHKEG9WQQBK7ZKY4PMK1	admin@medusa-test.com	f	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Imludml0ZV8wMUtRUEhTSEtFRzlXUVFCSzdaS1k0UE1LMSIsImVtYWlsIjoiYWRtaW5AbWVkdXNhLXRlc3QuY29tIiwiaWF0IjoxNzc3Nzk5NTc5LCJleHAiOjE3Nzc4ODU5NzksImp0aSI6IjJhNTgyMTI2LWYxMzctNDYxZi04MjExLTcwMDdiNmZmMTVmZCJ9.MgbCQ54DNnvs6vcq09UZf5Am2Ker8zE0FavdE8tD_DQ	2026-05-04 09:12:59.245+00	\N	2026-05-03 09:12:59.25+00	2026-05-03 09:12:59.25+00	\N
\.


--
-- Data for Name: invite_rbac_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invite_rbac_role (invite_id, rbac_role_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: link_module_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.link_module_migrations (id, table_name, link_descriptor, created_at) FROM stdin;
1	cart_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "cart", "fromModule": "cart"}	2026-05-03 09:12:53.265858
2	cart_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "cart", "fromModule": "cart"}	2026-05-03 09:12:53.276056
3	customer_account_holder	{"toModel": "account_holder", "toModule": "payment", "fromModel": "customer", "fromModule": "customer"}	2026-05-03 09:12:53.282417
4	location_fulfillment_provider	{"toModel": "fulfillment_provider", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2026-05-03 09:12:53.289384
5	location_fulfillment_set	{"toModel": "fulfillment_set", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2026-05-03 09:12:53.297912
6	invite_rbac_role	{"toModel": "rbac_role", "toModule": "rbac", "fromModel": "invite", "fromModule": "user"}	2026-05-03 09:12:53.306827
7	order_cart	{"toModel": "cart", "toModule": "cart", "fromModel": "order", "fromModule": "order"}	2026-05-03 09:12:53.316947
8	order_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "order", "fromModule": "order"}	2026-05-03 09:12:53.323969
9	order_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "order", "fromModule": "order"}	2026-05-03 09:12:53.329994
10	order_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "order", "fromModule": "order"}	2026-05-03 09:12:53.342168
11	return_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "return", "fromModule": "order"}	2026-05-03 09:12:53.348021
12	product_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "product", "fromModule": "product"}	2026-05-03 09:12:53.357064
13	product_shipping_profile	{"toModel": "shipping_profile", "toModule": "fulfillment", "fromModel": "product", "fromModule": "product"}	2026-05-03 09:12:53.363554
14	product_variant_inventory_item	{"toModel": "inventory", "toModule": "inventory", "fromModel": "variant", "fromModule": "product"}	2026-05-03 09:12:53.369442
15	product_variant_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "variant", "fromModule": "product"}	2026-05-03 09:12:53.379641
16	publishable_api_key_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "api_key", "fromModule": "api_key"}	2026-05-03 09:12:53.389201
17	region_payment_provider	{"toModel": "payment_provider", "toModule": "payment", "fromModel": "region", "fromModule": "region"}	2026-05-03 09:12:53.400945
18	sales_channel_stock_location	{"toModel": "location", "toModule": "stock_location", "fromModel": "sales_channel", "fromModule": "sales_channel"}	2026-05-03 09:12:53.410779
19	shipping_option_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "shipping_option", "fromModule": "fulfillment"}	2026-05-03 09:12:53.418931
20	user_rbac_role	{"toModel": "rbac_role", "toModule": "rbac", "fromModel": "user", "fromModule": "user"}	2026-05-03 09:12:53.429862
\.


--
-- Data for Name: location_fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.location_fulfillment_provider (stock_location_id, fulfillment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KQPHSEM3J9F24P547ZY11ENJ	manual_manual	locfp_01KQPHSEMAHT2Y75ZR2YV1YTDN	2026-05-03 09:12:56.20175+00	2026-05-07 03:52:28.387+00	2026-05-07 03:52:28.386+00
\.


--
-- Data for Name: location_fulfillment_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.location_fulfillment_set (stock_location_id, fulfillment_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KQPHSEM3J9F24P547ZY11ENJ	fuset_01KQPHSEMM1F56YMCQYP82RARJ	locfs_01KQPHSEN2MF3MR8CEBFPN0RBH	2026-05-03 09:12:56.225392+00	2026-05-07 03:52:28.389+00	2026-05-07 03:52:28.388+00
sloc_01KR093X1HRT484K9N255ZE7BD	fuset_01KR0944SBGKK3GSMA8Q0HFY5B	locfs_01KR0944T2RKFHKS5CEQ4CJK7M	2026-05-07 03:53:53.725677+00	2026-05-07 03:53:53.725677+00	\N
\.


--
-- Data for Name: mikro_orm_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mikro_orm_migrations (id, name, executed_at) FROM stdin;
1	Migration20240307161216	2026-05-03 09:12:48.286911+00
2	Migration20241210073813	2026-05-03 09:12:48.286911+00
3	Migration20250106142624	2026-05-03 09:12:48.286911+00
4	Migration20250120110820	2026-05-03 09:12:48.286911+00
5	Migration20240307132720	2026-05-03 09:12:48.394976+00
6	Migration20240719123015	2026-05-03 09:12:48.394976+00
7	Migration20241213063611	2026-05-03 09:12:48.394976+00
8	Migration20251010131115	2026-05-03 09:12:48.394976+00
9	InitialSetup20240401153642	2026-05-03 09:12:48.535989+00
10	Migration20240601111544	2026-05-03 09:12:48.535989+00
11	Migration202408271511	2026-05-03 09:12:48.535989+00
12	Migration20241122120331	2026-05-03 09:12:48.535989+00
13	Migration20241125090957	2026-05-03 09:12:48.535989+00
14	Migration20250411073236	2026-05-03 09:12:48.535989+00
15	Migration20250516081326	2026-05-03 09:12:48.535989+00
16	Migration20250910154539	2026-05-03 09:12:48.535989+00
17	Migration20250911092221	2026-05-03 09:12:48.535989+00
18	Migration20250929204438	2026-05-03 09:12:48.535989+00
19	Migration20251008132218	2026-05-03 09:12:48.535989+00
20	Migration20251011090511	2026-05-03 09:12:48.535989+00
21	Migration20260224120000	2026-05-03 09:12:48.535989+00
22	Migration20260306120000	2026-05-03 09:12:48.535989+00
23	Migration20230929122253	2026-05-03 09:12:48.883357+00
24	Migration20240322094407	2026-05-03 09:12:48.883357+00
25	Migration20240322113359	2026-05-03 09:12:48.883357+00
26	Migration20240322120125	2026-05-03 09:12:48.883357+00
27	Migration20240626133555	2026-05-03 09:12:48.883357+00
28	Migration20240704094505	2026-05-03 09:12:48.883357+00
29	Migration20241127114534	2026-05-03 09:12:48.883357+00
30	Migration20241127223829	2026-05-03 09:12:48.883357+00
31	Migration20241128055359	2026-05-03 09:12:48.883357+00
32	Migration20241212190401	2026-05-03 09:12:48.883357+00
33	Migration20250408145122	2026-05-03 09:12:48.883357+00
34	Migration20250409122219	2026-05-03 09:12:48.883357+00
35	Migration20251009110625	2026-05-03 09:12:48.883357+00
36	Migration20251112192723	2026-05-03 09:12:48.883357+00
37	Migration20260429163502	2026-05-03 09:12:48.883357+00
38	Migration20240227120221	2026-05-03 09:12:49.197755+00
39	Migration20240617102917	2026-05-03 09:12:49.197755+00
40	Migration20240624153824	2026-05-03 09:12:49.197755+00
41	Migration20241211061114	2026-05-03 09:12:49.197755+00
42	Migration20250113094144	2026-05-03 09:12:49.197755+00
43	Migration20250120110700	2026-05-03 09:12:49.197755+00
44	Migration20250226130616	2026-05-03 09:12:49.197755+00
45	Migration20250508081510	2026-05-03 09:12:49.197755+00
46	Migration20250828075407	2026-05-03 09:12:49.197755+00
47	Migration20250909083125	2026-05-03 09:12:49.197755+00
48	Migration20250916120552	2026-05-03 09:12:49.197755+00
49	Migration20250917143818	2026-05-03 09:12:49.197755+00
50	Migration20250919122137	2026-05-03 09:12:49.197755+00
51	Migration20251006000000	2026-05-03 09:12:49.197755+00
52	Migration20251015113934	2026-05-03 09:12:49.197755+00
53	Migration20251107050148	2026-05-03 09:12:49.197755+00
54	Migration20240124154000	2026-05-03 09:12:49.481134+00
55	Migration20240524123112	2026-05-03 09:12:49.481134+00
56	Migration20240602110946	2026-05-03 09:12:49.481134+00
57	Migration20241211074630	2026-05-03 09:12:49.481134+00
58	Migration20251010130829	2026-05-03 09:12:49.481134+00
59	Migration20240115152146	2026-05-03 09:12:49.63847+00
60	Migration20240222170223	2026-05-03 09:12:49.739519+00
61	Migration20240831125857	2026-05-03 09:12:49.739519+00
62	Migration20241106085918	2026-05-03 09:12:49.739519+00
63	Migration20241205095237	2026-05-03 09:12:49.739519+00
64	Migration20241216183049	2026-05-03 09:12:49.739519+00
65	Migration20241218091938	2026-05-03 09:12:49.739519+00
66	Migration20250120115059	2026-05-03 09:12:49.739519+00
67	Migration20250212131240	2026-05-03 09:12:49.739519+00
68	Migration20250326151602	2026-05-03 09:12:49.739519+00
69	Migration20250508081553	2026-05-03 09:12:49.739519+00
70	Migration20251017153909	2026-05-03 09:12:49.739519+00
71	Migration20251208130704	2026-05-03 09:12:49.739519+00
72	Migration20240205173216	2026-05-03 09:12:49.975084+00
73	Migration20240624200006	2026-05-03 09:12:49.975084+00
74	Migration20250120110744	2026-05-03 09:12:49.975084+00
75	InitialSetup20240221144943	2026-05-03 09:12:50.120889+00
76	Migration20240604080145	2026-05-03 09:12:50.120889+00
77	Migration20241205122700	2026-05-03 09:12:50.120889+00
78	Migration20251015123842	2026-05-03 09:12:50.120889+00
79	InitialSetup20240227075933	2026-05-03 09:12:50.253193+00
80	Migration20240621145944	2026-05-03 09:12:50.253193+00
81	Migration20241206083313	2026-05-03 09:12:50.253193+00
82	Migration20251202184737	2026-05-03 09:12:50.253193+00
83	Migration20251212161429	2026-05-03 09:12:50.253193+00
84	Migration20240227090331	2026-05-03 09:12:50.395184+00
85	Migration20240710135844	2026-05-03 09:12:50.395184+00
86	Migration20240924114005	2026-05-03 09:12:50.395184+00
87	Migration20241212052837	2026-05-03 09:12:50.395184+00
88	InitialSetup20240228133303	2026-05-03 09:12:50.57127+00
89	Migration20240624082354	2026-05-03 09:12:50.57127+00
90	Migration20240225134525	2026-05-03 09:12:50.691319+00
91	Migration20240806072619	2026-05-03 09:12:50.691319+00
92	Migration20241211151053	2026-05-03 09:12:50.691319+00
93	Migration20250115160517	2026-05-03 09:12:50.691319+00
94	Migration20250120110552	2026-05-03 09:12:50.691319+00
95	Migration20250123122334	2026-05-03 09:12:50.691319+00
96	Migration20250206105639	2026-05-03 09:12:50.691319+00
97	Migration20250207132723	2026-05-03 09:12:50.691319+00
98	Migration20250625084134	2026-05-03 09:12:50.691319+00
99	Migration20250924135437	2026-05-03 09:12:50.691319+00
100	Migration20250929124701	2026-05-03 09:12:50.691319+00
101	Migration20240219102530	2026-05-03 09:12:50.930818+00
102	Migration20240604100512	2026-05-03 09:12:50.930818+00
103	Migration20240715102100	2026-05-03 09:12:50.930818+00
104	Migration20240715174100	2026-05-03 09:12:50.930818+00
105	Migration20240716081800	2026-05-03 09:12:50.930818+00
106	Migration20240801085921	2026-05-03 09:12:50.930818+00
107	Migration20240821164505	2026-05-03 09:12:50.930818+00
108	Migration20240821170920	2026-05-03 09:12:50.930818+00
109	Migration20240827133639	2026-05-03 09:12:50.930818+00
110	Migration20240902195921	2026-05-03 09:12:50.930818+00
111	Migration20240913092514	2026-05-03 09:12:50.930818+00
112	Migration20240930122627	2026-05-03 09:12:50.930818+00
113	Migration20241014142943	2026-05-03 09:12:50.930818+00
114	Migration20241106085223	2026-05-03 09:12:50.930818+00
115	Migration20241129124827	2026-05-03 09:12:50.930818+00
116	Migration20241217162224	2026-05-03 09:12:50.930818+00
117	Migration20250326151554	2026-05-03 09:12:50.930818+00
118	Migration20250522181137	2026-05-03 09:12:50.930818+00
119	Migration20250702095353	2026-05-03 09:12:50.930818+00
120	Migration20250704120229	2026-05-03 09:12:50.930818+00
121	Migration20250910130000	2026-05-03 09:12:50.930818+00
122	Migration20251016160403	2026-05-03 09:12:50.930818+00
123	Migration20251016182939	2026-05-03 09:12:50.930818+00
124	Migration20251017155709	2026-05-03 09:12:50.930818+00
125	Migration20251114100559	2026-05-03 09:12:50.930818+00
126	Migration20251125164002	2026-05-03 09:12:50.930818+00
127	Migration20251210112909	2026-05-03 09:12:50.930818+00
128	Migration20251210112924	2026-05-03 09:12:50.930818+00
129	Migration20251225120947	2026-05-03 09:12:50.930818+00
130	Migration20260106185528	2026-05-03 09:12:50.930818+00
131	Migration20250717162007	2026-05-03 09:12:51.541071+00
132	Migration20260127081758	2026-05-03 09:12:51.541071+00
133	Migration20240205025928	2026-05-03 09:12:51.73004+00
134	Migration20240529080336	2026-05-03 09:12:51.73004+00
135	Migration20241202100304	2026-05-03 09:12:51.73004+00
136	Migration20240214033943	2026-05-03 09:12:51.958321+00
137	Migration20240703095850	2026-05-03 09:12:51.958321+00
138	Migration20241202103352	2026-05-03 09:12:51.958321+00
139	Migration20240311145700_InitialSetupMigration	2026-05-03 09:12:52.146766+00
140	Migration20240821170957	2026-05-03 09:12:52.146766+00
141	Migration20240917161003	2026-05-03 09:12:52.146766+00
142	Migration20241217110416	2026-05-03 09:12:52.146766+00
143	Migration20250113122235	2026-05-03 09:12:52.146766+00
144	Migration20250120115002	2026-05-03 09:12:52.146766+00
145	Migration20250822130931	2026-05-03 09:12:52.146766+00
146	Migration20250825132614	2026-05-03 09:12:52.146766+00
147	Migration20251114133146	2026-05-03 09:12:52.146766+00
148	Migration20240509083918_InitialSetupMigration	2026-05-03 09:12:52.504506+00
149	Migration20240628075401	2026-05-03 09:12:52.504506+00
150	Migration20240830094712	2026-05-03 09:12:52.504506+00
151	Migration20250120110514	2026-05-03 09:12:52.504506+00
152	Migration20251028172715	2026-05-03 09:12:52.504506+00
153	Migration20251121123942	2026-05-03 09:12:52.504506+00
154	Migration20251121150408	2026-05-03 09:12:52.504506+00
155	Migration20231228143900	2026-05-03 09:12:52.80717+00
156	Migration20241206101446	2026-05-03 09:12:52.80717+00
157	Migration20250128174331	2026-05-03 09:12:52.80717+00
158	Migration20250505092459	2026-05-03 09:12:52.80717+00
159	Migration20250819104213	2026-05-03 09:12:52.80717+00
160	Migration20250819110924	2026-05-03 09:12:52.80717+00
161	Migration20250908080305	2026-05-03 09:12:52.80717+00
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification (id, "to", channel, template, data, trigger_type, resource_id, resource_type, receiver_id, original_notification_id, idempotency_key, external_id, provider_id, created_at, updated_at, deleted_at, status, "from", provider_data) FROM stdin;
noti_01KR020F6NEX74K84SE7KDV3JZ		feed	admin-ui	{"title": "Product import", "description": "Product import of file medusa_import_corrected.csv completed successfully!"}	\N	\N	\N	\N	\N	\N	\N	local	2026-05-07 01:49:33.27+00	2026-05-07 01:49:33.29+00	\N	success	\N	\N
\.


--
-- Data for Name: notification_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification_provider (id, handle, name, is_enabled, channels, created_at, updated_at, deleted_at) FROM stdin;
local	local	local	t	{feed}	2026-05-03 09:12:55.147+00	2026-05-03 09:12:55.147+00	\N
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."order" (id, region_id, display_id, customer_id, version, sales_channel_id, status, is_draft_order, email, currency_code, shipping_address_id, billing_address_id, no_notification, metadata, created_at, updated_at, deleted_at, canceled_at, custom_display_id, locale) FROM stdin;
\.


--
-- Data for Name: order_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_cart; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_cart (order_id, cart_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_change; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_change (id, order_id, version, description, status, internal_note, created_by, requested_by, requested_at, confirmed_by, confirmed_at, declined_by, declined_reason, metadata, declined_at, canceled_by, canceled_at, created_at, updated_at, change_type, deleted_at, return_id, claim_id, exchange_id, carry_over_promotions) FROM stdin;
\.


--
-- Data for Name: order_change_action; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_change_action (id, order_id, version, ordering, order_change_id, reference, reference_id, action, details, amount, raw_amount, internal_note, applied, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_claim; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_claim (id, order_id, return_id, order_version, display_id, type, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_claim_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_claim_item (id, claim_id, item_id, is_additional_item, reason, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_claim_item_image; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_claim_item_image (id, claim_item_id, url, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_credit_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_credit_line (id, order_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: order_exchange; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_exchange (id, order_id, return_id, order_version, display_id, no_notification, allow_backorder, difference_due, raw_difference_due, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_exchange_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_exchange_item (id, exchange_id, item_id, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_fulfillment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_fulfillment (order_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_item (id, order_id, version, item_id, quantity, raw_quantity, fulfilled_quantity, raw_fulfilled_quantity, shipped_quantity, raw_shipped_quantity, return_requested_quantity, raw_return_requested_quantity, return_received_quantity, raw_return_received_quantity, return_dismissed_quantity, raw_return_dismissed_quantity, written_off_quantity, raw_written_off_quantity, metadata, created_at, updated_at, deleted_at, delivered_quantity, raw_delivered_quantity, unit_price, raw_unit_price, compare_at_unit_price, raw_compare_at_unit_price) FROM stdin;
\.


--
-- Data for Name: order_line_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_line_item (id, totals_id, title, subtitle, thumbnail, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, is_custom_price, product_type_id, is_giftcard) FROM stdin;
\.


--
-- Data for Name: order_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, item_id, deleted_at, is_tax_inclusive, version) FROM stdin;
\.


--
-- Data for Name: order_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_line_item_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_payment_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_payment_collection (order_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_promotion (order_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping (id, order_id, version, shipping_method_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_shipping_method; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping_method (id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at, is_custom_amount) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, shipping_method_id, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping_method_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_summary; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_summary (id, order_id, version, totals, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_transaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_transaction (id, order_id, version, amount, raw_amount, currency_code, reference, reference_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment (id, amount, raw_amount, currency_code, provider_id, data, created_at, updated_at, deleted_at, captured_at, canceled_at, payment_collection_id, payment_session_id, metadata) FROM stdin;
\.


--
-- Data for Name: payment_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_collection (id, currency_code, amount, raw_amount, authorized_amount, raw_authorized_amount, captured_amount, raw_captured_amount, refunded_amount, raw_refunded_amount, created_at, updated_at, deleted_at, completed_at, status, metadata) FROM stdin;
\.


--
-- Data for Name: payment_collection_payment_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_collection_payment_providers (payment_collection_id, payment_provider_id) FROM stdin;
\.


--
-- Data for Name: payment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
pp_system_default	t	2026-05-03 09:12:55.143+00	2026-05-03 09:12:55.143+00	\N
\.


--
-- Data for Name: payment_session; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_session (id, currency_code, amount, raw_amount, provider_id, data, context, status, authorized_at, payment_collection_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price (id, title, price_set_id, currency_code, raw_amount, rules_count, created_at, updated_at, deleted_at, price_list_id, amount, min_quantity, max_quantity, raw_min_quantity, raw_max_quantity) FROM stdin;
price_01KR06N21DPM16656D012W3E6D	\N	pset_01KR06N21E8XB36KTT9Z8SVWYV	usd	{"value": "20", "precision": 20}	0	2026-05-07 03:10:42.223+00	2026-05-07 03:10:42.223+00	\N	\N	20	\N	\N	\N	\N
price_01KR06N21EV1XZ6VMJD062P9Y0	\N	pset_01KR06N21EK2PSYNYB9DP16HRA	usd	{"value": "20", "precision": 20}	0	2026-05-07 03:10:42.223+00	2026-05-07 03:10:42.223+00	\N	\N	20	\N	\N	\N	\N
price_01KR06N21E1ZPHD95EJTVS2N8Y	\N	pset_01KR06N21EW60TJ0EJRF5KMX10	usd	{"value": "20", "precision": 20}	0	2026-05-07 03:10:42.223+00	2026-05-07 03:10:42.223+00	\N	\N	20	\N	\N	\N	\N
price_01KR06N21EC684DR703Q2W09CJ	\N	pset_01KR06N21EA9GA9VZGVWBVE0P0	usd	{"value": "20", "precision": 20}	0	2026-05-07 03:10:42.223+00	2026-05-07 03:10:42.223+00	\N	\N	20	\N	\N	\N	\N
price_01KQPHSEPG39EKTMPWKVG3G8KV	\N	pset_01KQPHSEPGM621N1BRADDQTZVB	usd	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.444+00	2026-05-07 03:52:28.436+00	\N	10	\N	\N	\N	\N
price_01KQPHSEPG42Y4DYZTAK6BEH0G	\N	pset_01KQPHSEPGM621N1BRADDQTZVB	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.444+00	2026-05-07 03:52:28.436+00	\N	10	\N	\N	\N	\N
price_01KQPHSEPG41H2ZA6CJ46EMSKJ	\N	pset_01KQPHSEPGM621N1BRADDQTZVB	eur	{"value": "10", "precision": 20}	1	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.444+00	2026-05-07 03:52:28.436+00	\N	10	\N	\N	\N	\N
price_01KQPHSEPHYMC3GGZZA7V2VRCC	\N	pset_01KQPHSEPHREJ626MJP27FZS6A	usd	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.46+00	2026-05-07 03:52:28.436+00	\N	10	\N	\N	\N	\N
price_01KQPHSEPHR0FP4BWEZJ5QPSR5	\N	pset_01KQPHSEPHREJ626MJP27FZS6A	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.46+00	2026-05-07 03:52:28.436+00	\N	10	\N	\N	\N	\N
price_01KQPHSEPHBGP3X0QMWH8HT107	\N	pset_01KQPHSEPHREJ626MJP27FZS6A	eur	{"value": "10", "precision": 20}	1	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.46+00	2026-05-07 03:52:28.436+00	\N	10	\N	\N	\N	\N
price_01KR26GHCK45SJZVGY8T757CTZ	\N	pset_01KR26GHCMYDAHFKXA3GNDA67K	usd	{"value": "15.99", "precision": 20}	0	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KR26GHCMVWFHTXA75HPCMB7B	\N	pset_01KR26GHCMYDAHFKXA3GNDA67K	usd	{"value": "15.99", "precision": 20}	1	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KR26GHCMA40A1VS4SJMW34KJ	\N	pset_01KR26GHCNRKZT40BZF2JDQKDR	usd	{"value": "15.99", "precision": 20}	0	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KR26GHCNYKDC4ESSK0YEP9W3	\N	pset_01KR26GHCNRKZT40BZF2JDQKDR	usd	{"value": "15.99", "precision": 20}	1	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KR26GHCNVJ1P0701D2SFER4R	\N	pset_01KR26GHCPFVX660RM1SWW57AQ	usd	{"value": "15.99", "precision": 20}	0	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KQPHSEW6EB03AGR6191WVBHE	\N	pset_01KQPHSEW75VT588CR0SGZZ27P	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.663+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW7M4GBPT594YQA7D1N	\N	pset_01KQPHSEW75VT588CR0SGZZ27P	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.663+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW7PCSY8F1RQYSVKGCB	\N	pset_01KQPHSEW7DBKKBV76YYJ02DMT	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.669+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW7AA5BZ6E82NMP2C8A	\N	pset_01KQPHSEW7DBKKBV76YYJ02DMT	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.669+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW737M167MEB861ENNG	\N	pset_01KQPHSEW7WCS4HNXYC9KTT2PF	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.673+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW71PFT2B0FDYMFDHJS	\N	pset_01KQPHSEW7WCS4HNXYC9KTT2PF	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.673+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW7KZJ37MXA3NZCZ9FR	\N	pset_01KQPHSEW8GZQBW4C188XJ902T	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.679+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW927JX074QXW6DSKJH	\N	pset_01KQPHSEW9HDK74QFRQSJPN4TW	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:17:02.308+00	2026-05-03 18:17:02.303+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW9SJ8VNBMTDK67EYWD	\N	pset_01KQPHSEW9HDK74QFRQSJPN4TW	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:17:02.308+00	2026-05-03 18:17:02.303+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW97ABWVKXXWDTQCM13	\N	pset_01KQPHSEWAYVESARFBEC2BTV2G	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:02.318+00	2026-05-03 18:17:02.303+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW9ZBPNQWQ1C9CNBS88	\N	pset_01KQPHSEWAYVESARFBEC2BTV2G	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:02.318+00	2026-05-03 18:17:02.303+00	\N	15	\N	\N	\N	\N
price_01KQPHSEWABKXK365CKXJ5SQ6C	\N	pset_01KQPHSEWA89AASFWWTHZ8E642	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:02.326+00	2026-05-03 18:17:02.303+00	\N	10	\N	\N	\N	\N
price_01KQPHSEWA41KBQ0SKCHDZWA99	\N	pset_01KQPHSEWA89AASFWWTHZ8E642	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:02.326+00	2026-05-03 18:17:02.303+00	\N	15	\N	\N	\N	\N
price_01KQPHSEWA45JYWK8663J56YV0	\N	pset_01KQPHSEWASR9022TASSGTJAEC	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:02.331+00	2026-05-03 18:17:02.303+00	\N	10	\N	\N	\N	\N
price_01KQPHSEWAWGAR81H26FHS1Q1X	\N	pset_01KQPHSEWASR9022TASSGTJAEC	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:02.331+00	2026-05-03 18:17:02.303+00	\N	15	\N	\N	\N	\N
price_01KQPHSEWAX5SMME582NGT2PN1	\N	pset_01KQPHSEWAF8P7TC2EZPNZTQ1Z	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.203+00	2026-05-03 18:17:06.199+00	\N	10	\N	\N	\N	\N
price_01KQPHSEWA88TQTM43ED91WEES	\N	pset_01KQPHSEWAF8P7TC2EZPNZTQ1Z	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.203+00	2026-05-03 18:17:06.199+00	\N	15	\N	\N	\N	\N
price_01KQPHSEWAMPBMFJYHBXGM5D3J	\N	pset_01KQPHSEWAQRX9SPBGQANKP81Q	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.211+00	2026-05-03 18:17:06.199+00	\N	10	\N	\N	\N	\N
price_01KQPHSEWAG2QSF1TQV4FWHYNZ	\N	pset_01KQPHSEWAQRX9SPBGQANKP81Q	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.211+00	2026-05-03 18:17:06.199+00	\N	15	\N	\N	\N	\N
price_01KQPHSEWA0H6KKD35Q6704CTS	\N	pset_01KQPHSEWAS12A2QX7ABPG5FSB	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.216+00	2026-05-03 18:17:06.199+00	\N	10	\N	\N	\N	\N
price_01KQPHSEWAPV022T19F18REYHS	\N	pset_01KQPHSEWAS12A2QX7ABPG5FSB	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.216+00	2026-05-03 18:17:06.199+00	\N	15	\N	\N	\N	\N
price_01KQPHSEWBDEPCK4FNRWHGPW2Y	\N	pset_01KQPHSEWBZZ0M85KS23P8SG30	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.222+00	2026-05-03 18:17:06.199+00	\N	10	\N	\N	\N	\N
price_01KQPJ7G4JQ99FM7PR7KJ6SB6E	\N	pset_01KQPJ7G4JFR9DVF871PRD3E1T	usd	{"value": "1799", "precision": 20}	0	2026-05-03 09:20:36.498+00	2026-05-07 02:52:47.96+00	2026-05-07 02:52:47.947+00	\N	1799	\N	\N	\N	\N
price_01KQPJ7G4HBXTNBY9RE9NAEDQ3	\N	pset_01KQPJ7G4JP5MMS1AVFW2P5GZD	usd	{"value": "1799", "precision": 20}	0	2026-05-03 09:20:36.498+00	2026-05-07 02:53:04.711+00	2026-05-07 02:53:04.706+00	\N	1799	\N	\N	\N	\N
price_01KQPHSEW8DEST3AC6RMMPEBW7	\N	pset_01KQPHSEW95V710Q9JD43H56MC	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.629+00	2026-05-03 18:16:54.623+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW96907FP1ZBBHQ80AY	\N	pset_01KQPHSEW95V710Q9JD43H56MC	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.629+00	2026-05-03 18:16:54.623+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW9H9V7FQTHTRC7BM04	\N	pset_01KQPHSEW93NHF7CTSE01687DX	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.638+00	2026-05-03 18:16:54.623+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW92S8A6K9DX2N4TQ8T	\N	pset_01KQPHSEW93NHF7CTSE01687DX	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.638+00	2026-05-03 18:16:54.623+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW9AGC7X3WTP42YG7BV	\N	pset_01KQPHSEW928VS0864BHB91VNC	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.642+00	2026-05-03 18:16:54.623+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW9QSVCJXXDRD0R910Z	\N	pset_01KQPHSEW928VS0864BHB91VNC	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.642+00	2026-05-03 18:16:54.623+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW90H1V1J0V8R0F4EF9	\N	pset_01KQPHSEW9J4ZT87H195FKSJWS	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.647+00	2026-05-03 18:16:54.623+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW9F6A2GQYKK1PYDTBN	\N	pset_01KQPHSEW9J4ZT87H195FKSJWS	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.647+00	2026-05-03 18:16:54.623+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW7AVX5VT0Q521J684W	\N	pset_01KQPHSEW8GZQBW4C188XJ902T	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.679+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW8XT8566CH2HV0H2H7	\N	pset_01KQPHSEW85GKD6WGDHBAMD0EN	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.685+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW82JXW2JJS773VJGJP	\N	pset_01KQPHSEW85GKD6WGDHBAMD0EN	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.685+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW8S1YGRKSB3S23YKNT	\N	pset_01KQPHSEW8JNMTXJRXCQYDRZMB	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.691+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW8A8C5Q05EXXRC6Z5B	\N	pset_01KQPHSEW8JNMTXJRXCQYDRZMB	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.691+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW8GG3K2WE3YZT85CAA	\N	pset_01KQPHSEW8BPD1GAQC1QGZYVEX	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.697+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW8NPNQPADPVGBEHFTT	\N	pset_01KQPHSEW8BPD1GAQC1QGZYVEX	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.697+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEW8ED7T9R45V2SV08KV	\N	pset_01KQPHSEW84NXZG0ABCN356EBT	eur	{"value": "10", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.704+00	2026-05-03 18:16:58.659+00	\N	10	\N	\N	\N	\N
price_01KQPHSEW85BA1BZK91P5HTMKX	\N	pset_01KQPHSEW84NXZG0ABCN356EBT	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.704+00	2026-05-03 18:16:58.659+00	\N	15	\N	\N	\N	\N
price_01KQPHSEWB4168PHTEGJF18MNH	\N	pset_01KQPHSEWBZZ0M85KS23P8SG30	usd	{"value": "15", "precision": 20}	0	2026-05-03 09:12:56.46+00	2026-05-03 18:17:06.222+00	2026-05-03 18:17:06.199+00	\N	15	\N	\N	\N	\N
price_01KQPJ7G4JT4YHM8N0DXD85CX2	\N	pset_01KQPJ7G4JKDRV6CYGNHHGTSD5	usd	{"value": "1499", "precision": 20}	0	2026-05-03 09:20:36.498+00	2026-05-03 18:17:14.672+00	2026-05-03 18:17:14.669+00	\N	1499	\N	\N	\N	\N
price_01KR21MGJ0ZN9A07XQ1ZXGT787	\N	pset_01KR21MGJ2K3CXCZKTY7HSPH19	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 20:21:30.306+00	2026-05-07 21:19:12.995+00	2026-05-07 21:19:12.988+00	\N	19.99	\N	\N	\N	\N
price_01KR21MGJ2PS4R4MPPHDEPSMK4	\N	pset_01KR21MGJ2K3CXCZKTY7HSPH19	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 20:21:30.306+00	2026-05-07 21:19:12.995+00	2026-05-07 21:19:12.988+00	\N	19.99	\N	\N	\N	\N
price_01KR26GHCPCRZ1PJR0YAMRPWHK	\N	pset_01KR26GHCPFVX660RM1SWW57AQ	usd	{"value": "15.99", "precision": 20}	1	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KR26GHCP8DPDZKYEKNJXXJWB	\N	pset_01KR26GHCQ1Z04N3KF057Z8J1Q	usd	{"value": "15.99", "precision": 20}	0	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KR26GHCQ2QTNM44E43PBKTHV	\N	pset_01KR26GHCQ1Z04N3KF057Z8J1Q	usd	{"value": "15.99", "precision": 20}	1	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	\N	15.99	\N	\N	\N	\N
price_01KR020EZW0WKSGZEKHSRQ50N5	\N	pset_01KR020EZWG3DFD68NPXQ621M2	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.341+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZW30DXEQNEBR3SWRED	\N	pset_01KR020EZW1WW3C5K69MDQ4AG7	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.362+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZY5QVF8ZJ70RTESNKZ	\N	pset_01KR020EZYV4SDYP00WWQAFV61	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.183+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZY3FGV364Y1KM2H4YX	\N	pset_01KR020EZYW4MP27R6H16RPVJS	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.19+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZYMKE4GTT6QR1YKB39	\N	pset_01KR020EZYEGG7NASAVSMATX0S	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.194+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZYNB2WNW79E3TFH1P5	\N	pset_01KR020EZY0FJ43ZZ8Y2344N7Y	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.198+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZYDYYE5SKSEZG49PW8	\N	pset_01KR020EZYAG6828PN9VJBDD9D	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.202+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZYY90FBPSRTVHM5AQ8	\N	pset_01KR020EZY33QJXHSY1K2HC01H	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.206+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZZB3F06G4EYHM20YXA	\N	pset_01KR020EZZ1YEMH7WA26FSPHX3	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.21+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZZGRAT4J7KJZ6BJWC4	\N	pset_01KR020EZZDR8B2E7VVYTJBKFM	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.214+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020EZZSQ9ZS4KESZD79K4P	\N	pset_01KR020EZZ9QG5WT1Q9KHY0AN6	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.221+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR250JDMASKJ9S0TWE9EDCBC	\N	pset_01KR250JDNAN15YRV4M79G1KDV	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 21:20:31.157+00	2026-05-07 21:20:31.157+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR250JDNXEYMBM7W7GGCN7ME	\N	pset_01KR250JDNAN15YRV4M79G1KDV	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 21:20:31.157+00	2026-05-07 21:20:31.157+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0RC0DPB3MJ85Q0PG7K	\N	pset_01KR2AAB0SAFNDT6FQ5C82SCJ1	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 22:53:14.141+00	2026-05-07 22:53:14.141+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0SXYRE0H0Z9YZST509	\N	pset_01KR2AAB0SAFNDT6FQ5C82SCJ1	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0SMCJ1X0GHJF0JW499	\N	pset_01KR2AAB0T5W87FQQ3MP4DSFGM	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0SX67VP3P6SCFVB31Q	\N	pset_01KR2AAB0T5W87FQQ3MP4DSFGM	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0TYW3FV1CG71QKH6QM	\N	pset_01KR2AAB0VA5MWDS8T7E0C48YM	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0TSDX9K8ER4K94V3AT	\N	pset_01KR2AAB0VA5MWDS8T7E0C48YM	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0VFFKC808DRKM37VQ3	\N	pset_01KR2AAB0WTZPHGV80BE5A1N3W	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2AAB0VE001YTNB1TGY1T72	\N	pset_01KR2AAB0WTZPHGV80BE5A1N3W	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR020EZZBM2AEB8B25B1YN7N	\N	pset_01KR020EZZFG3YTHXT7EE1YV1T	usd	{"value": "16.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:53.859+00	2026-05-07 02:27:53.856+00	\N	16.49	\N	\N	\N	\N
price_01KR020EZZEJ40J0PG4ZF9CV37	\N	pset_01KR020EZZT8TPJ1YT38HKG6AJ	usd	{"value": "16.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:53.865+00	2026-05-07 02:27:53.856+00	\N	16.49	\N	\N	\N	\N
price_01KR020EZZYAHGMEYBM0T7RVJ3	\N	pset_01KR020EZZ20QS9R6KNT5XWDD2	usd	{"value": "16.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:53.881+00	2026-05-07 02:27:53.856+00	\N	16.49	\N	\N	\N	\N
price_01KR020F00ATM9KP803YZP7HBG	\N	pset_01KR020F002PQRN05215BN8HZD	usd	{"value": "16.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:53.886+00	2026-05-07 02:27:53.856+00	\N	16.49	\N	\N	\N	\N
price_01KR020F005S4SV5T39CF859JE	\N	pset_01KR020F00JHGJEGEAHB2WYNKW	usd	{"value": "16.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:53.891+00	2026-05-07 02:27:53.856+00	\N	16.49	\N	\N	\N	\N
price_01KR251F10QNS0J5N1V6HCNWHP	\N	pset_01KR251F10MRSSP2A5NGDX60JD	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 21:21:00.449+00	2026-05-07 21:21:00.449+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR251F10QNF8Y12ZT6N9YN80	\N	pset_01KR251F10MRSSP2A5NGDX60JD	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 21:21:00.449+00	2026-05-07 21:21:00.449+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2CNPR2ZDX8147K0N4CBH7Q	\N	pset_01KR2CNPR2P1MQ4SY7DZQ558P0	usd	{"value": "3.99", "precision": 20}	0	2026-05-07 23:34:23.747+00	2026-05-07 23:34:23.747+00	\N	\N	3.99	\N	\N	\N	\N
price_01KR2CNPR2CQF7DHA8R2B8VDPV	\N	pset_01KR2CNPR2P1MQ4SY7DZQ558P0	usd	{"value": "3.99", "precision": 20}	1	2026-05-07 23:34:23.747+00	2026-05-07 23:34:23.747+00	\N	\N	3.99	\N	\N	\N	\N
price_01KR020EZWDYNRHXV9G8TZJVNQ	\N	pset_01KR020EZWTCPRAWQ9A21D7B3S	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.375+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZWSQAHJ5990VTAA55T	\N	pset_01KR020EZWZBH73B4SB9WKV55S	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.384+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZWFRRX6TRVH49B8ETX	\N	pset_01KR020EZW7ARZ9SHZNGW7EQ51	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.388+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZXCQ8W0VQEN5ME7G7Q	\N	pset_01KR020EZXXHXH35FXKP1866EG	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.393+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZXS92092H2GTDJJW89	\N	pset_01KR020EZXS07B3MBVQMHNP34C	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.398+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZXT7M0J6ZTBR3NV4M1	\N	pset_01KR020EZX682M721TD0S34SJQ	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.403+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZXFHR3HBT5G0104VAW	\N	pset_01KR020EZX4YZ78DFZM0MVSEX9	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.407+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020EZY0MDBN97JAXQTBVMT	\N	pset_01KR020EZYAPSNC4ADMXKM4FKK	usd	{"value": "13.49", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:45.411+00	2026-05-07 02:27:45.329+00	\N	13.49	\N	\N	\N	\N
price_01KR020F00J3HZZEXCYTE37H88	\N	pset_01KR020F00XNNBC8J8XDF34AK9	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.357+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F00BH6K0541H2XXBABW	\N	pset_01KR020F00J4HFHN1T9R2QXQYP	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.369+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F00F7GXAQPWAMAXH25K	\N	pset_01KR020F007EQSH7F8CB9R93GJ	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.375+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F0047J150RX2EZ761NN	\N	pset_01KR020F000KBVN1DZMR5VNSV3	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.382+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F00M210GWJPBX7QV0X2	\N	pset_01KR020F00A8SZTX09E2CXGH8E	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.39+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F01EZ4SGNGXTVZV8Z3D	\N	pset_01KR020F01H1SW1Q8J72S8ME98	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.395+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F013HBG6A6YSK72YARS	\N	pset_01KR020F018ASFQF27JQNDGY47	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.401+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F015MQK701BZWRKZVCK	\N	pset_01KR020F011Z3NMMQR92XHFE2J	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.406+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F01FA1J8TZGP9G9B094	\N	pset_01KR020F01F1E4K7EK555GPC5G	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.412+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F01X95DC67S95NS2N6A	\N	pset_01KR020F0181KDED3CCYJ0ESZD	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.419+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F02EXRAP7D5E20DQZKG	\N	pset_01KR020F02DP6PSQMX1DP67PQ6	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.424+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F025XE8H30V7M33WQ0P	\N	pset_01KR020F02XBNVPMMGT051QVHA	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.432+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F02CSTNRVC9DRKH2A8F	\N	pset_01KR020F02NHW8BPX263FY7XPA	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.441+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F02X8390PJ4HPY2BKF0	\N	pset_01KR020F022B40NMM9FQM59552	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.45+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F027Z3XR8VQYA7V0XVJ	\N	pset_01KR020F02C2SDV590YHE74S1C	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.457+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F02A8CR8V9ATB9KM17R	\N	pset_01KR020F02AY7MXZ9VT5DNGRYS	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.464+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F02QTHDMA1W35Y34EET	\N	pset_01KR020F03VC8B4RTFG6AMANWV	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.47+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F03MCNBGCER78HBA6P4	\N	pset_01KR020F03TP2H3FNR85QEQ3VZ	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.476+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F03944RPGGYED47VZ8T	\N	pset_01KR020F0301MYRV87A2SCH2PB	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.484+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F03RPPSQV46XQGQ6Z6A	\N	pset_01KR020F033EF5DRTZWM3N2G5V	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.492+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F03JMJN5RCPFX8A6WRG	\N	pset_01KR020F038DTDA1HXVWBC0YA0	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.499+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F03T803KEBRB2Q43TZX	\N	pset_01KR020F0311NPJW5ANR881CCV	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.505+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F03XDH1XYTTCQ2GX4KN	\N	pset_01KR020F031HE59WPCPQXRKN8B	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.51+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F03KNHSRVK1KSCRV4AN	\N	pset_01KR020F0433KZCNPJEH8TQ3FH	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.517+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F04N97SYC9X558SAS9W	\N	pset_01KR020F04R1SYHXPWNE2AQ430	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.524+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F041MP912F1N01F7EGK	\N	pset_01KR020F04GHET4VF74YJTJFD9	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.532+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F06JSDWPPXMTR95WJHV	\N	pset_01KR020F06AJKGSTDHGKDXNM8W	usd	{"value": "14.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:28:02.999+00	2026-05-07 02:28:02.996+00	\N	14.99	\N	\N	\N	\N
price_01KR020F06YTXYBX4YNWVJM08B	\N	pset_01KR020F06NQX7565A9HFRT3EG	usd	{"value": "14.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:28:03.004+00	2026-05-07 02:28:02.996+00	\N	14.99	\N	\N	\N	\N
price_01KR020F04MKVAFRTG4PQSBR38	\N	pset_01KR020F043VKB54TBSV6SM7Z8	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.537+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F044E3D2PC150F7YWXX	\N	pset_01KR020F04GHB8E9HGGB5ERXEZ	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.543+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F04TF32R5HCH4KGZBVH	\N	pset_01KR020F042E7YBAXJZJYA2QYJ	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.55+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F04KQJGGDFES708R538	\N	pset_01KR020F044QSXS9T710KVF231	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.558+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F04ZM79AAABH7TA2DRG	\N	pset_01KR020F04ZJTJ4CM43K6KDKMV	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.564+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F05BV0007CAW4T7AZJT	\N	pset_01KR020F05AHRPV04KJNK49VJW	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:48.57+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F05YAJ5T724F61BG3M9	\N	pset_01KR020F05A3CFH84658JQFVYE	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:27:48.577+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F058ZVST6NSD2RWK8NS	\N	pset_01KR020F05XE0BFR53R12NGJHH	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:27:48.584+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F05NHPRZVRPPAJWSVGV	\N	pset_01KR020F05MJREMKF91VTNCEZG	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:27:48.591+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F058JW0684STR1P60XN	\N	pset_01KR020F05TM84SJGZ6G46005R	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:27:48.597+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F05WD2QTNKZ4666NKBR	\N	pset_01KR020F05R6T08B4439P807JB	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:27:48.603+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F05JHPH37AV43B3KE61	\N	pset_01KR020F058YFPM95647EZ8N0S	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:27:48.609+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR020F06DPVS1CWH5ZEC07E6	\N	pset_01KR020F06AN1N6DNPH94M7ZCN	usd	{"value": "26.99", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:27:48.615+00	2026-05-07 02:27:48.335+00	\N	26.99	\N	\N	\N	\N
price_01KR252HJQ08PK95HNZTPBTBH2	\N	pset_01KR252HJQNQGHEPJ46N6GYZAT	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 21:21:35.832+00	2026-05-07 21:21:35.832+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR252HJQFDFJK2QQ8DS30GAD	\N	pset_01KR252HJQNQGHEPJ46N6GYZAT	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 21:21:35.832+00	2026-05-07 21:21:35.832+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR020EZZ6EWDEA8EJBVXRR2Y	\N	pset_01KR020EZZREZTFTA0PFG2PY6R	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 01:49:33.065+00	2026-05-07 02:27:50.228+00	2026-05-07 02:27:50.178+00	\N	19.99	\N	\N	\N	\N
price_01KR020F060VQCYVBHTZX39XD8	\N	pset_01KR020F06Q8HBRE5XZ9ZF84X1	usd	{"value": "15.49", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:28:00.123+00	2026-05-07 02:28:00.12+00	\N	15.49	\N	\N	\N	\N
price_01KR020F067WTPSSQ4RVXECSAD	\N	pset_01KR020F06M3PQ3MH72CEQWJAK	usd	{"value": "15.49", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:28:00.129+00	2026-05-07 02:28:00.12+00	\N	15.49	\N	\N	\N	\N
price_01KR020F06TCYM82QDGJ2V65PV	\N	pset_01KR020F064R81GTA0CHD0SBRC	usd	{"value": "15.49", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:28:00.133+00	2026-05-07 02:28:00.12+00	\N	15.49	\N	\N	\N	\N
price_01KR020F069KAZA8CGBM8FW40R	\N	pset_01KR020F06YAP3ADDTM8Z9DP6V	usd	{"value": "15.49", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:28:00.137+00	2026-05-07 02:28:00.12+00	\N	15.49	\N	\N	\N	\N
price_01KR020F07188VTWRN2EBJBC6Q	\N	pset_01KR020F079T4D5S2ZQ9VWQN79	usd	{"value": "15.49", "precision": 20}	0	2026-05-07 01:49:33.066+00	2026-05-07 02:28:00.143+00	2026-05-07 02:28:00.12+00	\N	15.49	\N	\N	\N	\N
price_01KR2535HW5X56ZR4Z1DRM77BY	\N	pset_01KR2535HX9D5M70ST8Y1Q109P	usd	{"value": "19.99", "precision": 20}	0	2026-05-07 21:21:56.285+00	2026-05-07 21:21:56.285+00	\N	\N	19.99	\N	\N	\N	\N
price_01KR2535HXJ4SRKMRVJA0T9XFM	\N	pset_01KR2535HX9D5M70ST8Y1Q109P	usd	{"value": "19.99", "precision": 20}	1	2026-05-07 21:21:56.285+00	2026-05-07 21:21:56.285+00	\N	\N	19.99	\N	\N	\N	\N
\.


--
-- Data for Name: price_list; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_list (id, status, starts_at, ends_at, rules_count, title, description, type, created_at, updated_at, deleted_at, metadata) FROM stdin;
\.


--
-- Data for Name: price_list_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_list_rule (id, price_list_id, created_at, updated_at, deleted_at, value, attribute) FROM stdin;
\.


--
-- Data for Name: price_preference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_preference (id, attribute, value, is_tax_inclusive, created_at, updated_at, deleted_at) FROM stdin;
prpref_01KQPHSEJECYFF8BHHP5AAX3B7	currency_code	eur	f	2026-05-03 09:12:56.143+00	2026-05-03 09:12:56.143+00	\N
prpref_01KQPHSEJFCV04MYKRW8MHWBR4	currency_code	usd	f	2026-05-03 09:12:56.143+00	2026-05-03 09:12:56.143+00	\N
prpref_01KQPHSEKGCRFQH7KFM58R0JPA	region_id	reg_01KQPHSEJPZDMT8EQSZPG1VX8A	f	2026-05-03 09:12:56.176+00	2026-05-03 09:12:56.176+00	\N
prpref_01KR074QWHC1JCK0667C3NG240	region_id	reg_01KR074QV3K2MQR2HSR2MWXZK5	f	2026-05-07 03:19:16.113+00	2026-05-07 03:19:16.114+00	\N
\.


--
-- Data for Name: price_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_rule (id, value, priority, price_id, created_at, updated_at, deleted_at, attribute, operator) FROM stdin;
prule_01KQPHSEPGH6574NN6F832F9RQ	reg_01KQPHSEJPZDMT8EQSZPG1VX8A	0	price_01KQPHSEPG41H2ZA6CJ46EMSKJ	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.454+00	2026-05-07 03:52:28.436+00	region_id	eq
prule_01KQPHSEPHRB1M4BCCE701D7DG	reg_01KQPHSEJPZDMT8EQSZPG1VX8A	0	price_01KQPHSEPHBGP3X0QMWH8HT107	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.465+00	2026-05-07 03:52:28.436+00	region_id	eq
prule_01KR21MGJ2EQSNQNNE5RM9E3XT	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR21MGJ2PS4R4MPPHDEPSMK4	2026-05-07 20:21:30.307+00	2026-05-07 21:19:13.005+00	2026-05-07 21:19:12.988+00	region_id	eq
prule_01KR250JDNQXAZQ6EZA068SYCM	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR250JDNXEYMBM7W7GGCN7ME	2026-05-07 21:20:31.157+00	2026-05-07 21:20:31.157+00	\N	region_id	eq
prule_01KR251F10GH47F5V53MAWJP18	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR251F10QNF8Y12ZT6N9YN80	2026-05-07 21:21:00.449+00	2026-05-07 21:21:00.449+00	\N	region_id	eq
prule_01KR252HJQ3N5B74MFECMS1XMX	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR252HJQFDFJK2QQ8DS30GAD	2026-05-07 21:21:35.832+00	2026-05-07 21:21:35.832+00	\N	region_id	eq
prule_01KR2535HXK9GF1AK2ZMXJJ7J6	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR2535HXJ4SRKMRVJA0T9XFM	2026-05-07 21:21:56.285+00	2026-05-07 21:21:56.285+00	\N	region_id	eq
prule_01KR26GHCMF1C3MABMWVNBDXQ8	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR26GHCMVWFHTXA75HPCMB7B	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	region_id	eq
prule_01KR26GHCNKYB1ZH4S9AGWA8M3	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR26GHCNYKDC4ESSK0YEP9W3	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	region_id	eq
prule_01KR26GHCPGANGZ4GA3QQGZQZJ	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR26GHCPCRZ1PJR0YAMRPWHK	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	region_id	eq
prule_01KR26GHCQ02AGGXTS0WEAMVB5	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR26GHCQ2QTNM44E43PBKTHV	2026-05-07 21:46:42.968+00	2026-05-07 21:46:42.968+00	\N	region_id	eq
prule_01KR2AAB0SJJM0HPBMTZ8XN8B2	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR2AAB0SXYRE0H0Z9YZST509	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	region_id	eq
prule_01KR2AAB0S1ZF1552ZVSMW1KPR	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR2AAB0SX67VP3P6SCFVB31Q	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	region_id	eq
prule_01KR2AAB0TFTP4EADEW95X9HK6	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR2AAB0TSDX9K8ER4K94V3AT	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	region_id	eq
prule_01KR2AAB0V8G6W0GYGZEFHHNJB	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR2AAB0VE001YTNB1TGY1T72	2026-05-07 22:53:14.142+00	2026-05-07 22:53:14.142+00	\N	region_id	eq
prule_01KR2CNPR23CDBK5CB9WY9BP6R	reg_01KR074QV3K2MQR2HSR2MWXZK5	0	price_01KR2CNPR2CQF7DHA8R2B8VDPV	2026-05-07 23:34:23.747+00	2026-05-07 23:34:23.747+00	\N	region_id	eq
\.


--
-- Data for Name: price_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_set (id, created_at, updated_at, deleted_at) FROM stdin;
pset_01KQPJ7G4JFR9DVF871PRD3E1T	2026-05-03 09:20:36.498+00	2026-05-07 02:52:47.948+00	2026-05-07 02:52:47.947+00
pset_01KQPJ7G4JP5MMS1AVFW2P5GZD	2026-05-03 09:20:36.498+00	2026-05-07 02:53:04.706+00	2026-05-07 02:53:04.706+00
pset_01KR06N21E8XB36KTT9Z8SVWYV	2026-05-07 03:10:42.222+00	2026-05-07 03:10:42.223+00	\N
pset_01KR06N21EK2PSYNYB9DP16HRA	2026-05-07 03:10:42.223+00	2026-05-07 03:10:42.223+00	\N
pset_01KR06N21EW60TJ0EJRF5KMX10	2026-05-07 03:10:42.223+00	2026-05-07 03:10:42.223+00	\N
pset_01KR06N21EA9GA9VZGVWBVE0P0	2026-05-07 03:10:42.223+00	2026-05-07 03:10:42.223+00	\N
pset_01KQPHSEPGM621N1BRADDQTZVB	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.437+00	2026-05-07 03:52:28.436+00
pset_01KQPHSEPHREJ626MJP27FZS6A	2026-05-03 09:12:56.273+00	2026-05-07 03:52:28.454+00	2026-05-07 03:52:28.436+00
pset_01KR250JDNAN15YRV4M79G1KDV	2026-05-07 21:20:31.157+00	2026-05-07 21:20:31.157+00	\N
pset_01KR252HJQNQGHEPJ46N6GYZAT	2026-05-07 21:21:35.832+00	2026-05-07 21:21:35.832+00	\N
pset_01KR26GHCMYDAHFKXA3GNDA67K	2026-05-07 21:46:42.967+00	2026-05-07 21:46:42.967+00	\N
pset_01KR26GHCNRKZT40BZF2JDQKDR	2026-05-07 21:46:42.967+00	2026-05-07 21:46:42.967+00	\N
pset_01KR26GHCPFVX660RM1SWW57AQ	2026-05-07 21:46:42.967+00	2026-05-07 21:46:42.967+00	\N
pset_01KR26GHCQ1Z04N3KF057Z8J1Q	2026-05-07 21:46:42.967+00	2026-05-07 21:46:42.967+00	\N
pset_01KR2CNPR2P1MQ4SY7DZQ558P0	2026-05-07 23:34:23.747+00	2026-05-07 23:34:23.747+00	\N
pset_01KQPHSEW95V710Q9JD43H56MC	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.624+00	2026-05-03 18:16:54.623+00
pset_01KQPHSEW93NHF7CTSE01687DX	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.635+00	2026-05-03 18:16:54.623+00
pset_01KQPHSEW928VS0864BHB91VNC	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.64+00	2026-05-03 18:16:54.623+00
pset_01KQPHSEW9J4ZT87H195FKSJWS	2026-05-03 09:12:56.459+00	2026-05-03 18:16:54.645+00	2026-05-03 18:16:54.623+00
pset_01KQPHSEW75VT588CR0SGZZ27P	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.659+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW7DBKKBV76YYJ02DMT	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.666+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW7WCS4HNXYC9KTT2PF	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.671+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW8GZQBW4C188XJ902T	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.676+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW85GKD6WGDHBAMD0EN	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.683+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW8JNMTXJRXCQYDRZMB	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.688+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW8BPD1GAQC1QGZYVEX	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.695+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW84NXZG0ABCN356EBT	2026-05-03 09:12:56.459+00	2026-05-03 18:16:58.701+00	2026-05-03 18:16:58.659+00
pset_01KQPHSEW9HDK74QFRQSJPN4TW	2026-05-03 09:12:56.459+00	2026-05-03 18:17:02.303+00	2026-05-03 18:17:02.303+00
pset_01KQPHSEWAYVESARFBEC2BTV2G	2026-05-03 09:12:56.459+00	2026-05-03 18:17:02.314+00	2026-05-03 18:17:02.303+00
pset_01KQPHSEWA89AASFWWTHZ8E642	2026-05-03 09:12:56.459+00	2026-05-03 18:17:02.322+00	2026-05-03 18:17:02.303+00
pset_01KQPHSEWASR9022TASSGTJAEC	2026-05-03 09:12:56.459+00	2026-05-03 18:17:02.329+00	2026-05-03 18:17:02.303+00
pset_01KQPHSEWAF8P7TC2EZPNZTQ1Z	2026-05-03 09:12:56.459+00	2026-05-03 18:17:06.199+00	2026-05-03 18:17:06.199+00
pset_01KQPHSEWAQRX9SPBGQANKP81Q	2026-05-03 09:12:56.459+00	2026-05-03 18:17:06.208+00	2026-05-03 18:17:06.199+00
pset_01KQPHSEWAS12A2QX7ABPG5FSB	2026-05-03 09:12:56.459+00	2026-05-03 18:17:06.214+00	2026-05-03 18:17:06.199+00
pset_01KQPHSEWBZZ0M85KS23P8SG30	2026-05-03 09:12:56.459+00	2026-05-03 18:17:06.22+00	2026-05-03 18:17:06.199+00
pset_01KQPJ7G4JKDRV6CYGNHHGTSD5	2026-05-03 09:20:36.498+00	2026-05-03 18:17:14.669+00	2026-05-03 18:17:14.669+00
pset_01KR020EZWG3DFD68NPXQ621M2	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.329+00	2026-05-07 02:27:45.329+00
pset_01KR020EZW1WW3C5K69MDQ4AG7	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.357+00	2026-05-07 02:27:45.329+00
pset_01KR020EZWTCPRAWQ9A21D7B3S	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.366+00	2026-05-07 02:27:45.329+00
pset_01KR020EZWZBH73B4SB9WKV55S	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.379+00	2026-05-07 02:27:45.329+00
pset_01KR020EZW7ARZ9SHZNGW7EQ51	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.386+00	2026-05-07 02:27:45.329+00
pset_01KR020EZXXHXH35FXKP1866EG	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.391+00	2026-05-07 02:27:45.329+00
pset_01KR020EZXS07B3MBVQMHNP34C	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.395+00	2026-05-07 02:27:45.329+00
pset_01KR020EZX682M721TD0S34SJQ	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.4+00	2026-05-07 02:27:45.329+00
pset_01KR020EZX4YZ78DFZM0MVSEX9	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.405+00	2026-05-07 02:27:45.329+00
pset_01KR020EZYAPSNC4ADMXKM4FKK	2026-05-07 01:49:33.064+00	2026-05-07 02:27:45.409+00	2026-05-07 02:27:45.329+00
pset_01KR020F00XNNBC8J8XDF34AK9	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.335+00	2026-05-07 02:27:48.335+00
pset_01KR020F00J4HFHN1T9R2QXQYP	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.364+00	2026-05-07 02:27:48.335+00
pset_01KR020F007EQSH7F8CB9R93GJ	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.372+00	2026-05-07 02:27:48.335+00
pset_01KR020F000KBVN1DZMR5VNSV3	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.379+00	2026-05-07 02:27:48.335+00
pset_01KR020F00A8SZTX09E2CXGH8E	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.387+00	2026-05-07 02:27:48.335+00
pset_01KR020F01H1SW1Q8J72S8ME98	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.392+00	2026-05-07 02:27:48.335+00
pset_01KR020F018ASFQF27JQNDGY47	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.398+00	2026-05-07 02:27:48.335+00
pset_01KR020F011Z3NMMQR92XHFE2J	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.404+00	2026-05-07 02:27:48.335+00
pset_01KR020F01F1E4K7EK555GPC5G	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.409+00	2026-05-07 02:27:48.335+00
pset_01KR020F0181KDED3CCYJ0ESZD	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.414+00	2026-05-07 02:27:48.335+00
pset_01KR020F02DP6PSQMX1DP67PQ6	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.422+00	2026-05-07 02:27:48.335+00
pset_01KR020F02XBNVPMMGT051QVHA	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.428+00	2026-05-07 02:27:48.335+00
pset_01KR020F02NHW8BPX263FY7XPA	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.436+00	2026-05-07 02:27:48.335+00
pset_01KR020F022B40NMM9FQM59552	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.446+00	2026-05-07 02:27:48.335+00
pset_01KR020F02C2SDV590YHE74S1C	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.454+00	2026-05-07 02:27:48.335+00
pset_01KR020F02AY7MXZ9VT5DNGRYS	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.461+00	2026-05-07 02:27:48.335+00
pset_01KR020EZYV4SDYP00WWQAFV61	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.179+00	2026-05-07 02:27:50.178+00
pset_01KR020EZYW4MP27R6H16RPVJS	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.186+00	2026-05-07 02:27:50.178+00
pset_01KR020EZYEGG7NASAVSMATX0S	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.192+00	2026-05-07 02:27:50.178+00
pset_01KR020EZY0FJ43ZZ8Y2344N7Y	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.196+00	2026-05-07 02:27:50.178+00
pset_01KR020EZYAG6828PN9VJBDD9D	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.2+00	2026-05-07 02:27:50.178+00
pset_01KR020EZY33QJXHSY1K2HC01H	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.204+00	2026-05-07 02:27:50.178+00
pset_01KR020EZZ1YEMH7WA26FSPHX3	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.208+00	2026-05-07 02:27:50.178+00
pset_01KR020EZZDR8B2E7VVYTJBKFM	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.211+00	2026-05-07 02:27:50.178+00
pset_01KR020EZZ9QG5WT1Q9KHY0AN6	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.218+00	2026-05-07 02:27:50.178+00
pset_01KR020EZZREZTFTA0PFG2PY6R	2026-05-07 01:49:33.064+00	2026-05-07 02:27:50.224+00	2026-05-07 02:27:50.178+00
pset_01KR020EZZFG3YTHXT7EE1YV1T	2026-05-07 01:49:33.064+00	2026-05-07 02:27:53.856+00	2026-05-07 02:27:53.856+00
pset_01KR020EZZT8TPJ1YT38HKG6AJ	2026-05-07 01:49:33.064+00	2026-05-07 02:27:53.862+00	2026-05-07 02:27:53.856+00
pset_01KR020EZZ20QS9R6KNT5XWDD2	2026-05-07 01:49:33.064+00	2026-05-07 02:27:53.868+00	2026-05-07 02:27:53.856+00
pset_01KR020F002PQRN05215BN8HZD	2026-05-07 01:49:33.064+00	2026-05-07 02:27:53.884+00	2026-05-07 02:27:53.856+00
pset_01KR020F00JHGJEGEAHB2WYNKW	2026-05-07 01:49:33.064+00	2026-05-07 02:27:53.888+00	2026-05-07 02:27:53.856+00
pset_01KR21MGJ2K3CXCZKTY7HSPH19	2026-05-07 20:21:30.306+00	2026-05-07 21:19:12.988+00	2026-05-07 21:19:12.988+00
pset_01KR251F10MRSSP2A5NGDX60JD	2026-05-07 21:21:00.449+00	2026-05-07 21:21:00.449+00	\N
pset_01KR2535HX9D5M70ST8Y1Q109P	2026-05-07 21:21:56.285+00	2026-05-07 21:21:56.285+00	\N
pset_01KR2AAB0SAFNDT6FQ5C82SCJ1	2026-05-07 22:53:14.14+00	2026-05-07 22:53:14.14+00	\N
pset_01KR2AAB0T5W87FQQ3MP4DSFGM	2026-05-07 22:53:14.14+00	2026-05-07 22:53:14.14+00	\N
pset_01KR2AAB0VA5MWDS8T7E0C48YM	2026-05-07 22:53:14.14+00	2026-05-07 22:53:14.14+00	\N
pset_01KR2AAB0WTZPHGV80BE5A1N3W	2026-05-07 22:53:14.14+00	2026-05-07 22:53:14.14+00	\N
pset_01KR020F03VC8B4RTFG6AMANWV	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.467+00	2026-05-07 02:27:48.335+00
pset_01KR020F03TP2H3FNR85QEQ3VZ	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.473+00	2026-05-07 02:27:48.335+00
pset_01KR020F0301MYRV87A2SCH2PB	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.479+00	2026-05-07 02:27:48.335+00
pset_01KR020F033EF5DRTZWM3N2G5V	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.488+00	2026-05-07 02:27:48.335+00
pset_01KR020F038DTDA1HXVWBC0YA0	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.495+00	2026-05-07 02:27:48.335+00
pset_01KR020F0311NPJW5ANR881CCV	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.502+00	2026-05-07 02:27:48.335+00
pset_01KR020F031HE59WPCPQXRKN8B	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.508+00	2026-05-07 02:27:48.335+00
pset_01KR020F0433KZCNPJEH8TQ3FH	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.514+00	2026-05-07 02:27:48.335+00
pset_01KR020F04R1SYHXPWNE2AQ430	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.521+00	2026-05-07 02:27:48.335+00
pset_01KR020F04GHET4VF74YJTJFD9	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.527+00	2026-05-07 02:27:48.335+00
pset_01KR020F043VKB54TBSV6SM7Z8	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.534+00	2026-05-07 02:27:48.335+00
pset_01KR020F04GHB8E9HGGB5ERXEZ	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.54+00	2026-05-07 02:27:48.335+00
pset_01KR020F042E7YBAXJZJYA2QYJ	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.547+00	2026-05-07 02:27:48.335+00
pset_01KR020F044QSXS9T710KVF231	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.555+00	2026-05-07 02:27:48.335+00
pset_01KR020F04ZJTJ4CM43K6KDKMV	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.56+00	2026-05-07 02:27:48.335+00
pset_01KR020F05AHRPV04KJNK49VJW	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.567+00	2026-05-07 02:27:48.335+00
pset_01KR020F05A3CFH84658JQFVYE	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.573+00	2026-05-07 02:27:48.335+00
pset_01KR020F05XE0BFR53R12NGJHH	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.58+00	2026-05-07 02:27:48.335+00
pset_01KR020F05MJREMKF91VTNCEZG	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.588+00	2026-05-07 02:27:48.335+00
pset_01KR020F05TM84SJGZ6G46005R	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.594+00	2026-05-07 02:27:48.335+00
pset_01KR020F05R6T08B4439P807JB	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.6+00	2026-05-07 02:27:48.335+00
pset_01KR020F058YFPM95647EZ8N0S	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.606+00	2026-05-07 02:27:48.335+00
pset_01KR020F06AN1N6DNPH94M7ZCN	2026-05-07 01:49:33.064+00	2026-05-07 02:27:48.612+00	2026-05-07 02:27:48.335+00
pset_01KR020F06Q8HBRE5XZ9ZF84X1	2026-05-07 01:49:33.064+00	2026-05-07 02:28:00.12+00	2026-05-07 02:28:00.12+00
pset_01KR020F06M3PQ3MH72CEQWJAK	2026-05-07 01:49:33.064+00	2026-05-07 02:28:00.127+00	2026-05-07 02:28:00.12+00
pset_01KR020F064R81GTA0CHD0SBRC	2026-05-07 01:49:33.064+00	2026-05-07 02:28:00.131+00	2026-05-07 02:28:00.12+00
pset_01KR020F06YAP3ADDTM8Z9DP6V	2026-05-07 01:49:33.064+00	2026-05-07 02:28:00.135+00	2026-05-07 02:28:00.12+00
pset_01KR020F079T4D5S2ZQ9VWQN79	2026-05-07 01:49:33.064+00	2026-05-07 02:28:00.141+00	2026-05-07 02:28:00.12+00
pset_01KR020F06AJKGSTDHGKDXNM8W	2026-05-07 01:49:33.064+00	2026-05-07 02:28:02.996+00	2026-05-07 02:28:02.996+00
pset_01KR020F06NQX7565A9HFRT3EG	2026-05-07 01:49:33.064+00	2026-05-07 02:28:03.001+00	2026-05-07 02:28:02.996+00
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product (id, title, handle, subtitle, description, is_giftcard, status, thumbnail, weight, length, height, width, origin_country, hs_code, mid_code, material, collection_id, type_id, discountable, external_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	Medusa Sweatshirt	sweatshirt	\N	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.607+00	2026-05-03 18:16:54.606+00	\N
prod_01KQPHSERAFDQSTVMMVTCQJ5PC	Medusa T-Shirt	t-shirt	\N	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-03 09:12:56.336+00	2026-05-03 18:16:58.643+00	2026-05-03 18:16:58.643+00	\N
prod_01KQPHSERBDBQMVHYR2D3TKKJY	Medusa Sweatpants	sweatpants	\N	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.283+00	2026-05-03 18:17:02.283+00	\N
prod_01KQPHSERBX5WG7WWAYKMHKVE8	Medusa Shorts	shorts	\N	Reimagine the feeling of classic shorts. With our cotton shorts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.185+00	2026-05-03 18:17:06.185+00	\N
prod_01KQPJ7G1DRW1S8AMV6AP72KDB	Wave	wave	\N	Wave disposable vape.	f	published	https://bayblaze.net/wp-content/uploads/2026/03/wave.png	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-03 09:20:36.401+00	2026-05-03 18:17:14.659+00	2026-05-03 18:17:14.659+00	\N
prod_01KR020EPM5X42055YHXD2VB8M	Raz VUE Pre-filled Replacement Pod (50000 Puffs)	raz-vue-pre-filled-replacement-pod-50000-puffs	\N	Take your Raz VUE system to the next level with this high-capacity pre-filled replacement pod, delivering up to 50,000 puffs in Normal Mode or 25,000 puffs in Boost Mode. Dual Mode power output lets you choose between 12W Endurance Mode for extended sessions or 24W Flavor Burst Mode for denser, more intense clouds — all backed by a Dual Mesh Coil for consistent, flavorful vapor from the first puff to the last. The pod holds 13mL of e-liquid at 50mg (5%) nicotine strength and is equipped with a transparent tank and side HD screen so you can always check your levels at a glance. A 420mAh battery and adjustable airflow round out a feature-packed pod built for vapers who refuse to compromise on performance or longevity.	f	draft	images/raz-vue-pre-filled-replacement-pod-50000-puffs/00.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-07 01:49:32.783+00	2026-05-07 02:27:45.285+00	2026-05-07 02:27:45.284+00	\N
prod_01KR020EPN1524QFK6KV5KQFT5	Raz LTX Disposable (25000 Puffs) - Buy 1 Get 1 Free	raz-ltx-disposable-25000-puffs-buy-1-get-1-free	\N	The Raz LTX by Geek Vape is a premium 25,000-puff disposable wrapped in genuine leather for a luxurious feel that stands out from the crowd. It delivers up to 25K puffs in Regular Mode or 15K in Boost Mode, powered by an 800mAh USB-C rechargeable battery and loaded with 16mL of 50mg nicotine e-liquid. A Mega HD display screen shows battery life, e-liquid levels, and even vaping and charging animations, while wattage adjustment and switchable light/dark display modes let you tailor every session. Built-in short-circuit and overcharging protections keep things safe — and right now it's Buy 1 Get 1 Free when you add 2 to your cart.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:48.301+00	2026-05-07 02:27:48.3+00	\N
prod_01KR020EPNMAV2M74GW005XGRD	Raz RX Disposable (50000 Puffs)	raz-rx-disposable-50000-puffs	\N	The Raz RX by Geek Vape brings up to 50,000 puffs in a strikingly styled device featuring a premium 3D curved screen that keeps key info front and center. Three output modes — Normal (50K puffs), Boost (25K), and Super Boost (20K) — let you dial in exactly the experience you want, with 9 wattage airflow modes for even finer control. A generously sized 19mL e-liquid reservoir, 1000mAh rechargeable battery, USB-C charging port, 4 light modes, and 50mg nicotine strength make this a top-tier choice for vapers who demand both performance and style. Available in five distinct color variants: Code Blue, Code Green, Code Pink, Code Red, and Code White.	f	draft	images/raz-rx-disposable-50000-puffs/00.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:53.846+00	2026-05-07 02:27:53.846+00	\N
prod_01KR020EPNY1RZMM5WJNCQ66HB	Geekvape Raz DC25000 Disposable (25000 Puffs)	geekvape-raz-dc25000-disposable-25000-puffs	\N	The Geekvape Raz DC25000 sets the bar for hassle-free disposable vaping, delivering up to 25,000 puffs from a compact, pocket-friendly body loaded with 16mL of 50mg nicotine e-liquid. An integrated 800mAh rechargeable battery with a USB-C port keeps you powered up, while LED indicators for both e-liquid level and battery life — plus a Turbo Boost mode — ensure you're always in the loop. Advanced temperature control and a precision coil system work together to produce rich, consistent flavor and vapor from the first draw to the last.	f	draft	images/geekvape-raz-dc25000-disposable-25000-puffs/00.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:28:02.986+00	2026-05-07 02:28:02.986+00	\N
prod_01KQPJ7G1DGCS8J83FXCGA00S8	Lost Mary MT35000 Turbo	lost-mary-mt35000-turbo	\N	Lost Mary MT35000 Turbo disposable vape.	f	published	https://bayblaze.net/wp-content/uploads/2026/03/LMMTK35K.png	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-03 09:20:36.401+00	2026-05-07 02:52:47.894+00	2026-05-07 02:52:47.892+00	\N
prod_01KQPJ7G1DHT5KBQDV18K81HN8	RAZ LTX 25000 (Gush Edition)	raz-ltx-25000-gush-edition	\N	Top-selling disposable vape from RAZ.	f	published	https://bayblaze.net/wp-content/uploads/2026/03/raz-ltx-25000-gush-edition-blue-raz-gush.png	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-03 09:20:36.401+00	2026-05-07 02:53:04.685+00	2026-05-07 02:53:04.682+00	\N
prod_01KR020EPNHR59Q1C2FZ7S4QH8	Raz VUE Kit Disposable (50000 Puffs)	raz-vue-kit-disposable-50000-puffs	\N	The Raz VUE Kit Disposable packs an impressive 50,000 puffs in Normal Mode (or 25,000 in Boost Mode), giving you the flexibility to match your session style. Choose between 12W Endurance Mode for extended draws or kick it up to 24W Flavor Burst Mode for richer, denser clouds — all backed by a Dual Mesh Coil for even, consistent heating from first puff to last. A combined 1320mAh battery system (420mAh pod + 900mAh reusable power bank), 13mL e-liquid capacity, transparent tank with an HD side display, adjustable airflow, and USB-C fast charging round out this feature-packed kit. Available in 10 bold flavors with 50mg nicotine strength.	f	draft	images/raz-vue-kit-disposable-50000-puffs/00.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:50.17+00	2026-05-07 02:27:50.17+00	\N
prod_01KR020EPNN8K97EZMCJFTC5R2	Raz LTX Zero Nicotine Disposable (25000 Puffs)	raz-ltx-zero-nicotine-disposable-25000-puffs	\N	For vapers who want the full Raz LTX experience without any nicotine, the Raz LTX Zero Nicotine Disposable delivers up to 25,000 puffs in Normal Mode and 15,000 in Boost Mode, all from a 16mL e-liquid capacity. The device is wrapped in genuine leather for a premium, durable feel, and is powered by an 800mAh USB-C rechargeable battery for fast, efficient top-ups. Adjustable wattage, mesh coil technology, a draw-activated firing system, and a customizable smart screen with switchable light or dark display themes make it as versatile as it is stylish — a great fit for nicotine-free vapers of any experience level.	f	draft	images/raz-ltx-zero-nicotine-disposable-25000-puffs/00.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:28:00.112+00	2026-05-07 02:28:00.112+00	\N
prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	RAZ TN9000	raz-tn9000	\N	The RAZ TN9000 delivers a sleek, modern vaping experience with a high-definition screen, adjustable airflow, and up to 9,000 puffs. Designed for long-lasting use and smooth flavor, it combines convenience, performance, and style in one disposable device.	f	published	http://localhost:9000/static/1778123442057-raz-tn900-main.jpg	\N	\N	\N	\N	\N	\N	\N	\N	pcol_01KR257K81RPYHK5QY1AAWV0BX	\N	t	\N	2026-05-07 03:10:42.118+00	2026-05-07 22:23:31.995+00	\N	{"brand": "RAZ", "spec_puffs": "Up to 9,000 puffs", "spec_capacity": "12mL", "spec_nicotine": "50mg"}
prod_01KR21MGDTXDF9B55TKB39PM04	Lost Mary MT35000 Turbo	lost-mary-mt35k-turbo		The MT35000 Turbo is a long-lasting disposable built for steady flavor, smooth vapor, and extended battery life.	f	published	http://localhost:9000/static/1778185290122-LMMTK35K.png	\N	\N	\N	\N	\N	\N	\N	\N	pcol_01KR257K81RPYHK5QY1AAWV0BX	ptyp_01KR06YYR7V5FX6JBNSSGQBC9V	t	\N	2026-05-07 20:21:30.175+00	2026-05-07 21:24:50.688+00	\N	{"brand": "Lost Mary", "spec_puffs": "Up to 35,000 regular / 20,000 turbo", "spec_capacity": "18mL", "spec_nicotine": "50mg"}
prod_01KR26GH2MNKJP9X74ZMA3NPQV	Geek Bar Pulse 15000	geek-bar-pulse-15k		The Geek Bar Pulse 15000 is a rechargeable disposable vape designed for long-lasting use, smooth flavor, and convenient performance. It features a full-screen display, a 650mAh rechargeable battery, and two output modes: regular mode for up to 15,000 puffs and pulse mode for up to 7,500 puffs. With 16mL of 5% nicotine salt e-liquid, dual-core technology, and dual-mesh coils, the Geek Bar Pulse delivers consistent flavor and vapor production throughout the device. It comes prefilled, pre-charged, and ready to use in a wide variety of flavor options.	f	published	http://localhost:9000/static/1778190402520-Geek-Bar-Pulse-15000-Disposable.png	\N	\N	\N	\N	\N	\N	\N	\N	pcol_01KR257K81RPYHK5QY1AAWV0BX	ptyp_01KR06YYR7V5FX6JBNSSGQBC9V	t	\N	2026-05-07 21:46:42.67+00	2026-05-07 21:50:58.351+00	\N	{"brand": "Geekbar", "spec_puffs": "Up to 15,000 puffs", "spec_capacity": "16mL", "spec_nicotine": "50mg"}
prod_01KR2AAAVPRZ3VG53QESA2AWGN	RAZ LTX 25000	raz-ltx-25k		The RAZ LTX Vape 25K is a disposable vape by RAZ that delivers up to 25,000 puffs in Normal Mode or 15,000 in Boost Mode. It features a dual mesh coil with temp control, adjustable airflow, and a rechargeable 800mAh battery with USB-C charging. With 16mL of 5% nicotine e-liquid and a vibrant HD display, it offers users bold Gush Edition flavors and a smooth, long-lasting vaping experience.	f	published	http://localhost:9000/static/1778194393878-RAZ-LTX-Disposable-Vape-25K.png	\N	\N	\N	\N	\N	\N	\N	\N	pcol_01KR257K81RPYHK5QY1AAWV0BX	ptyp_01KR06YYR7V5FX6JBNSSGQBC9V	t	\N	2026-05-07 22:53:13.986+00	2026-05-07 22:56:21.127+00	\N	{"brand": "RAZ", "spec_puffs": "Up to 25,000 puffs normal / 15,000 puffs boost", "spec_capacity": "16ml", "spec_nicotine": "50mg / 5%"}
prod_01KR2CNPM96BND9CVPP0R3GJWD	RAW Cones King Size (3 Pack)	raw-cones-king-3pk		RAW King Size Cones (3 Pack) come ready to fill for a quick, smooth smoke without the hassle of rolling by hand. Made with RAW’s classic unbleached paper, they burn slow and even, making them a convenient choice for everyday sessions.	f	published	http://localhost:9000/static/1778196863594-raw-king-cones-3pk.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	ptyp_01KR2CF0RNCNBY88W8ZQ1S6NBR	t	\N	2026-05-07 23:34:23.63+00	2026-05-07 23:34:37.684+00	\N	{"brand": "RAW"}
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_category (id, name, description, handle, mpath, is_active, is_internal, rank, parent_category_id, created_at, updated_at, deleted_at, metadata, external_id) FROM stdin;
pcat_01KQPJ7G13NF7019B2XWRZASQX	Accessories		accessories	pcat_01KQPJ7G13NF7019B2XWRZASQX	t	f	5	\N	2026-05-03 09:20:36.388+00	2026-05-07 04:12:39.319+00	2026-05-07 04:12:39.319+00	\N	\N
pcat_01KQPHSEQZCSG9QJCQSVTAXHW1	Merch		merch	pcat_01KQPHSEQZCSG9QJCQSVTAXHW1	t	f	3	\N	2026-05-03 09:12:56.319+00	2026-05-07 04:12:44.071+00	2026-05-07 04:12:44.07+00	\N	\N
pcat_01KQPHSEQYVTG8TDZTMQKNGET0	Sweatshirts		sweatshirts	pcat_01KQPHSEQYVTG8TDZTMQKNGET0	t	f	1	\N	2026-05-03 09:12:56.319+00	2026-05-07 04:12:47.203+00	2026-05-07 04:12:47.202+00	\N	\N
pcat_01KQPHSEQYDQRC8ETAG7QNE3R8	Pants		pants	pcat_01KQPHSEQYDQRC8ETAG7QNE3R8	t	f	1	\N	2026-05-03 09:12:56.319+00	2026-05-07 04:12:50.392+00	2026-05-07 04:12:50.392+00	\N	\N
pcat_01KQPHSEQX7T0G0Y5XK349S4WV	Shirts		shirts	pcat_01KQPHSEQX7T0G0Y5XK349S4WV	t	f	0	\N	2026-05-03 09:12:56.319+00	2026-05-07 04:12:53.202+00	2026-05-07 04:12:53.201+00	\N	\N
pcat_01KR2376N7M9TYK7J2Q0B611PR	Disposable Vapes	Disposable vapes offer a simple, ready-to-use option with no setup, charging hassle, or refilling required. Browse flavorful, portable devices built for smooth draws, convenient use, and on-the-go delivery.	disposable-vapes	pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ.pcat_01KR2376N7M9TYK7J2Q0B611PR	t	f	0	pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ	2026-05-07 20:49:11.338+00	2026-05-07 20:49:11.338+00	\N	\N	\N
pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ	Vapes	Browse our vape selection for convenient, flavorful options including disposable devices, pod systems, and vape accessories. Find easy-to-use products built for portability, smooth draws, and everyday convenience.	vapes	pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ	t	f	0	\N	2026-05-03 09:20:36.387+00	2026-05-07 20:49:42.763+00	\N	\N	\N
pcat_01KR2C7F5HY2VJFVSS1J85B83Q	Smoking Accessories	Shop smoking accessories designed to make every session smoother, cleaner, and more convenient. Browse essentials like lighters, rolling papers, cones, grinders, trays, and storage items built for easy use at home or on the go.	smoking-accessories	pcat_01KR2C7F5HY2VJFVSS1J85B83Q	t	f	1	\N	2026-05-07 23:26:37.233+00	2026-05-07 23:26:37.233+00	\N	\N	\N
pcat_01KR2C9CNDMQ3AGSW36H37BXDA	Cones	Pre-rolled cones make rolling simple, quick, and consistent. Just pack, twist, and enjoy an easy smoking option with less mess and no hand-rolling needed.	cones	pcat_01KR2C7F5HY2VJFVSS1J85B83Q.pcat_01KR2CYRJ9FK98RVQ6CFD96TY0.pcat_01KR2C9CNDMQ3AGSW36H37BXDA	t	f	0	pcat_01KR2CYRJ9FK98RVQ6CFD96TY0	2026-05-07 23:27:40.205+00	2026-05-07 23:39:44.391+00	\N	\N	\N
pcat_01KR2CYRJ9FK98RVQ6CFD96TY0	Paper	Browse smoking papers and paper-based essentials for rolling, packing, and everyday use. Find convenient options like rolling papers, pre-rolled cones, and related accessories built for a cleaner, easier smoking experience	paper	pcat_01KR2C7F5HY2VJFVSS1J85B83Q.pcat_01KR2CYRJ9FK98RVQ6CFD96TY0	t	f	1	pcat_01KR2C7F5HY2VJFVSS1J85B83Q	2026-05-07 23:39:20.521+00	2026-05-07 23:44:10.794+00	\N	\N	\N
pcat_01KR2D7M1P22YGX98MCXP7KJ53	Lighters	Shop reliable lighters for everyday smoking needs, from classic disposable options to convenient pocket-sized styles. Easy to carry, simple to use, and perfect as an add-on essential.	lighters	pcat_01KR2C7F5HY2VJFVSS1J85B83Q.pcat_01KR2D7M1P22YGX98MCXP7KJ53	t	f	0	pcat_01KR2C7F5HY2VJFVSS1J85B83Q	2026-05-07 23:44:10.806+00	2026-05-07 23:44:10.806+00	\N	\N	\N
\.


--
-- Data for Name: product_category_product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_category_product (product_id, product_category_id) FROM stdin;
prod_01KQPHSERAFDQSTVMMVTCQJ5PC	pcat_01KQPHSEQX7T0G0Y5XK349S4WV
prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	pcat_01KQPHSEQYVTG8TDZTMQKNGET0
prod_01KQPHSERBDBQMVHYR2D3TKKJY	pcat_01KQPHSEQYDQRC8ETAG7QNE3R8
prod_01KQPHSERBX5WG7WWAYKMHKVE8	pcat_01KQPHSEQZCSG9QJCQSVTAXHW1
prod_01KQPJ7G1DHT5KBQDV18K81HN8	pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ
prod_01KQPJ7G1DGCS8J83FXCGA00S8	pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ
prod_01KQPJ7G1DRW1S8AMV6AP72KDB	pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ
prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	pcat_01KQPJ7G134BW2ATA9Q3VD2DDJ
prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	pcat_01KR2376N7M9TYK7J2Q0B611PR
prod_01KR21MGDTXDF9B55TKB39PM04	pcat_01KR2376N7M9TYK7J2Q0B611PR
prod_01KR26GH2MNKJP9X74ZMA3NPQV	pcat_01KR2376N7M9TYK7J2Q0B611PR
prod_01KR2AAAVPRZ3VG53QESA2AWGN	pcat_01KR2376N7M9TYK7J2Q0B611PR
prod_01KR2CNPM96BND9CVPP0R3GJWD	pcat_01KR2C9CNDMQ3AGSW36H37BXDA
\.


--
-- Data for Name: product_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_collection (id, title, handle, metadata, created_at, updated_at, deleted_at, external_id) FROM stdin;
pcol_01KR1YY951QSQHTWABE0D2FC73	Vapes	vapes	\N	2026-05-07 19:34:24.665043+00	2026-05-07 20:38:29.769+00	2026-05-07 20:38:29.766+00	\N
pcol_01KR22M4WYJTD7R45801SKFHHB	Lost Mary	lost-mary	\N	2026-05-07 20:38:46.934694+00	2026-05-07 21:23:57.946+00	2026-05-07 21:23:57.945+00	\N
pcol_01KR2390AW409EKHTST837VN2R	RAZ	raz	\N	2026-05-07 20:50:10.392745+00	2026-05-07 21:24:09.073+00	2026-05-07 21:24:09.073+00	\N
pcol_01KR257K81RPYHK5QY1AAWV0BX	Best Sellers	best-sellers	\N	2026-05-07 21:24:21.36825+00	2026-05-07 21:24:21.36825+00	\N	\N
\.


--
-- Data for Name: product_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_option (id, title, product_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
opt_01KQPHSERET68166MV1EPAMJQW	Size	prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.619+00	2026-05-03 18:16:54.606+00
opt_01KQPHSERD9FF7HZHRMV3DV6D0	Size	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00
opt_01KQPHSERDXGCY6J31K7FFPQ9P	Color	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00
opt_01KQPHSERFF4WM989C3K4FAZJN	Size	prod_01KQPHSERBDBQMVHYR2D3TKKJY	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.293+00	2026-05-03 18:17:02.283+00
opt_01KQPHSERGWGWBH5KXT5MW9A5B	Size	prod_01KQPHSERBX5WG7WWAYKMHKVE8	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.195+00	2026-05-03 18:17:06.185+00
opt_01KQPJ7G1GFQDGNPV3AEY1YDMC	Default	prod_01KQPJ7G1DRW1S8AMV6AP72KDB	\N	2026-05-03 09:20:36.402+00	2026-05-03 18:17:14.668+00	2026-05-03 18:17:14.659+00
opt_01KR020EQ15ZZXKQYKDSJ8BDF1	Flavor	prod_01KR020EPM5X42055YHXD2VB8M	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00
opt_01KR020EQC48QGTZGFC3YSK837	Flavor	prod_01KR020EPN1524QFK6KV5KQFT5	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00
opt_01KR020EQ63K4XWW9PKM0M7P2M	Flavor	prod_01KR020EPNHR59Q1C2FZ7S4QH8	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00
opt_01KR020EQ8MMJCQGTYKV9XCKAZ	Color	prod_01KR020EPNMAV2M74GW005XGRD	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00
opt_01KR020EQDDKDCR4XB40RDMGTP	Flavor	prod_01KR020EPNN8K97EZMCJFTC5R2	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00
opt_01KR020EQCRTP1X5AWJCGZECRS	Flavor	prod_01KR020EPNY1RZMM5WJNCQ66HB	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:28:02.994+00	2026-05-07 02:28:02.986+00
opt_01KQPJ7G1GBHCW63CH1NJN2AWW	Default	prod_01KQPJ7G1DGCS8J83FXCGA00S8	\N	2026-05-03 09:20:36.402+00	2026-05-07 02:52:47.914+00	2026-05-07 02:52:47.892+00
opt_01KQPJ7G1FNBX5D5CJT51FQFXF	Flavor	prod_01KQPJ7G1DHT5KBQDV18K81HN8	\N	2026-05-03 09:20:36.401+00	2026-05-07 02:53:04.703+00	2026-05-07 02:53:04.682+00
opt_01KR06N1Y5B550VM2M1EWYKV7R	Flavor	prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	\N	2026-05-07 03:10:42.119+00	2026-05-07 03:10:42.119+00	\N
opt_01KR21MGDXHFAR9GHY65R2G9H0	Flavor	prod_01KR21MGDTXDF9B55TKB39PM04	\N	2026-05-07 20:21:30.176+00	2026-05-07 21:15:16.088+00	2026-05-07 21:15:16.087+00
opt_01KR24SY84K2A5N11TY7YVW034	Flavor	prod_01KR21MGDTXDF9B55TKB39PM04	\N	2026-05-07 21:16:53.893+00	2026-05-07 21:16:53.893+00	\N
opt_01KR26GH2Y0PX39AZ487EABMQV	Flavor	prod_01KR26GH2MNKJP9X74ZMA3NPQV	\N	2026-05-07 21:46:42.676+00	2026-05-07 21:46:42.677+00	\N
opt_01KR2AAAW0DCMVVPSEFMFZKFB1	Flavor	prod_01KR2AAAVPRZ3VG53QESA2AWGN	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N
opt_01KR2CNPMBFWVGMGAKH06YHZKG	Default option	prod_01KR2CNPM96BND9CVPP0R3GJWD	\N	2026-05-07 23:34:23.631+00	2026-05-07 23:34:23.631+00	\N
\.


--
-- Data for Name: product_option_value; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_option_value (id, value, option_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
optval_01KQPJ7G1G4FX9AZ45XAHMJSZD	Default	opt_01KQPJ7G1GBHCW63CH1NJN2AWW	\N	2026-05-03 09:20:36.402+00	2026-05-07 02:52:47.935+00	2026-05-07 02:52:47.892+00
optval_01KQPJ7G1EHE8VQ4J4FJBDEDD2	Blue Raz Gush	opt_01KQPJ7G1FNBX5D5CJT51FQFXF	\N	2026-05-03 09:20:36.401+00	2026-05-07 02:53:04.709+00	2026-05-07 02:53:04.682+00
optval_01KR06N1Y4YDKGP2BHRFKQ2GC1	Miami Mint	opt_01KR06N1Y5B550VM2M1EWYKV7R	\N	2026-05-07 03:10:42.119+00	2026-05-07 03:10:42.119+00	\N
optval_01KR06N1Y4W2VFDF20WZADPGB4	Night Crawler	opt_01KR06N1Y5B550VM2M1EWYKV7R	\N	2026-05-07 03:10:42.119+00	2026-05-07 03:10:42.119+00	\N
optval_01KR06N1Y4QDWJQW1XBEM87V86	Blue Raz Ice	opt_01KR06N1Y5B550VM2M1EWYKV7R	\N	2026-05-07 03:10:42.119+00	2026-05-07 03:10:42.119+00	\N
optval_01KR06N1Y4SV920WJE5556FKHT	Strawberry Ice	opt_01KR06N1Y5B550VM2M1EWYKV7R	\N	2026-05-07 03:10:42.119+00	2026-05-07 03:10:42.119+00	\N
optval_01KR24XQW1BT5G8FBBXWXN554Z	Blue Razz Ice	opt_01KR24SY84K2A5N11TY7YVW034	\N	2026-05-07 21:18:58.418955+00	2026-05-07 21:18:58.418955+00	\N
optval_01KR24XQW2F2TR6V4ZB2KB475Y	Miami Mint	opt_01KR24SY84K2A5N11TY7YVW034	\N	2026-05-07 21:18:58.418955+00	2026-05-07 21:18:58.418955+00	\N
optval_01KR24XQW29T2MKFFBMEHQF47D	Watermelon Ice	opt_01KR24SY84K2A5N11TY7YVW034	\N	2026-05-07 21:18:58.418955+00	2026-05-07 21:18:58.418955+00	\N
optval_01KR24XQW2M4DQ3K1PWJMN5BQ6	Tobacco	opt_01KR24SY84K2A5N11TY7YVW034	\N	2026-05-07 21:18:58.418955+00	2026-05-07 21:18:58.418955+00	\N
optval_01KR2CNPMAA76WCEV79R4RXS62	Default option value	opt_01KR2CNPMBFWVGMGAKH06YHZKG	\N	2026-05-07 23:34:23.631+00	2026-05-07 23:34:23.631+00	\N
optval_01KQPHSERES56NGG2SVYMVVNEK	S	opt_01KQPHSERET68166MV1EPAMJQW	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.627+00	2026-05-03 18:16:54.606+00
optval_01KQPHSERETW9X7ND4YT4RMQ6W	M	opt_01KQPHSERET68166MV1EPAMJQW	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.627+00	2026-05-03 18:16:54.606+00
optval_01KQPHSERE5KW7G6HMSC3VAV4S	L	opt_01KQPHSERET68166MV1EPAMJQW	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.627+00	2026-05-03 18:16:54.606+00
optval_01KQPHSEREHZEZJGTF7D00SVH2	XL	opt_01KQPHSERET68166MV1EPAMJQW	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:54.627+00	2026-05-03 18:16:54.606+00
optval_01KQPHSERCNKFKJEZ817E5K44V	S	opt_01KQPHSERD9FF7HZHRMV3DV6D0	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.664+00	2026-05-03 18:16:58.643+00
optval_01KQPHSERCA7NY240XRCKMTRSK	M	opt_01KQPHSERD9FF7HZHRMV3DV6D0	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.664+00	2026-05-03 18:16:58.643+00
optval_01KQPHSERCXDDETR7KEXBQ3FSG	L	opt_01KQPHSERD9FF7HZHRMV3DV6D0	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.664+00	2026-05-03 18:16:58.643+00
optval_01KQPHSERC847BYCGG0WEN9BEZ	XL	opt_01KQPHSERD9FF7HZHRMV3DV6D0	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.664+00	2026-05-03 18:16:58.643+00
optval_01KQPHSERD8E9A844RECKE9707	Black	opt_01KQPHSERDXGCY6J31K7FFPQ9P	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.664+00	2026-05-03 18:16:58.643+00
optval_01KQPHSERDBQX9FBEBSXJ9CMRQ	White	opt_01KQPHSERDXGCY6J31K7FFPQ9P	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:16:58.664+00	2026-05-03 18:16:58.643+00
optval_01KQPHSERF5H8YZ3YN69RSVV1F	S	opt_01KQPHSERFF4WM989C3K4FAZJN	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.305+00	2026-05-03 18:17:02.283+00
optval_01KQPHSERFT30VPPJBSVC1956W	M	opt_01KQPHSERFF4WM989C3K4FAZJN	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.305+00	2026-05-03 18:17:02.283+00
optval_01KQPHSERFKGW6NEWEHP7VCRCB	L	opt_01KQPHSERFF4WM989C3K4FAZJN	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.305+00	2026-05-03 18:17:02.283+00
optval_01KQPHSERFWYPSMK5TPRK9QD2P	XL	opt_01KQPHSERFF4WM989C3K4FAZJN	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:02.305+00	2026-05-03 18:17:02.283+00
optval_01KQPHSERF3M6CMZQP6SWMP4S8	S	opt_01KQPHSERGWGWBH5KXT5MW9A5B	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.202+00	2026-05-03 18:17:06.185+00
optval_01KQPHSERFGN0THPCK0HZ0AN5Y	M	opt_01KQPHSERGWGWBH5KXT5MW9A5B	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.202+00	2026-05-03 18:17:06.185+00
optval_01KQPHSERFRGF2QK9YVB1V5DMY	L	opt_01KQPHSERGWGWBH5KXT5MW9A5B	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.202+00	2026-05-03 18:17:06.185+00
optval_01KQPHSERF8RJDY1H6HAVWSDHW	XL	opt_01KQPHSERGWGWBH5KXT5MW9A5B	\N	2026-05-03 09:12:56.337+00	2026-05-03 18:17:06.202+00	2026-05-03 18:17:06.185+00
optval_01KQPJ7G1G8Z8EFRQKZH1NYXJQ	Default	opt_01KQPJ7G1GFQDGNPV3AEY1YDMC	\N	2026-05-03 09:20:36.402+00	2026-05-03 18:17:14.674+00	2026-05-03 18:17:14.659+00
optval_01KR020EPS7XC82TNN1HWCHJWK	Miami Mint	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPSVJMJ15M1GP8GDB86	Polar Ice	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPTW0YANZR4ZX145MFR	Triple Berry Lime	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPTKJGG3WXKW7YNYXX4	Blue Raz Ice	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPTHCYM6ZA3S1708KNN	Hawaiian Punch	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPTYQ7N05MAQ6WNQA9T	Pineapple MTN Dew	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPVEQ7W2Z0BCXWCTFBX	Sour Apple Ice	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPVR1WEXPTPMK29JY30	Strawberry Blast	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPWGKHJ9BDV4XAZNKFS	Watermelon Ice	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EPWP6D8BSP4GYQFFWB6	White Gummy	opt_01KR020EQ15ZZXKQYKDSJ8BDF1	\N	2026-05-07 01:49:32.784+00	2026-05-07 02:27:45.347+00	2026-05-07 02:27:45.284+00
optval_01KR020EQ9JQVR15N116W3S7PN	Bangin Sour Berries	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQ440AF1RG2XJYPDQ4Z	Blue Raz Ice	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ4QPH5EMFNHWC1CR72	Hawaiian Punch	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ4FEMDZKEAHA4PBM7H	Miami Mint	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ550GXHWCE7PEQENH9	Pineapple MTN Dew	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ5KJPR83CDZMJAM3CV	Polar Ice	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ5F6FS2WM461W38KAZ	Sour Apple Ice	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ5V8P0NSYE52CQ85JQ	Strawberry Blast	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ5P50F4R8SF8WDJ1QS	Triple Berry Lime	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ5V8NZX3790A145Q37	Watermelon Ice	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ6PWGNZYTS84VNV539	White Gummy	opt_01KR020EQ63K4XWW9PKM0M7P2M	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:50.187+00	2026-05-07 02:27:50.17+00
optval_01KR020EQ760R0Y87KDK6VC9TV	Code Blue	opt_01KR020EQ8MMJCQGTYKV9XCKAZ	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.863+00	2026-05-07 02:27:53.846+00
optval_01KR020EQ8DC41B2EVV872AWW7	Code Green	opt_01KR020EQ8MMJCQGTYKV9XCKAZ	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.863+00	2026-05-07 02:27:53.846+00
optval_01KR020EQ8F2DW2JZETESVX5G0	Code Pink	opt_01KR020EQ8MMJCQGTYKV9XCKAZ	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.863+00	2026-05-07 02:27:53.846+00
optval_01KR020EQ8DNFG4ZN7HSQ3RW00	Code Red	opt_01KR020EQ8MMJCQGTYKV9XCKAZ	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.863+00	2026-05-07 02:27:53.846+00
optval_01KR020EQ8Z30RCXH3QTT671QF	Code White	opt_01KR020EQ8MMJCQGTYKV9XCKAZ	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:53.863+00	2026-05-07 02:27:53.846+00
optval_01KR21MGDWW9K1QSQ9HA5E0HA1	Baja Splash, Berry Burst, Blue Razz Ice, Blackberry Blueberry, Black Mint, Black Razz Lemon	opt_01KR21MGDXHFAR9GHY65R2G9H0	\N	2026-05-07 20:21:30.176+00	2026-05-07 21:15:16.098+00	2026-05-07 21:15:16.087+00
optval_01KR26GH2PR8ERW3YRAG5DV9BV	Miami Mint	opt_01KR26GH2Y0PX39AZ487EABMQV	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N
optval_01KR26GH2XCK11YR99V3Q6JM0B	Blue Razz Ice	opt_01KR26GH2Y0PX39AZ487EABMQV	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N
optval_01KR26GH2X6YQ0D0M2SEV2KX3A	Berry Bliss	opt_01KR26GH2Y0PX39AZ487EABMQV	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N
optval_01KR26GH2XFYV0BN5JZ5E3P8FZ	Blueberry Watermelon	opt_01KR26GH2Y0PX39AZ487EABMQV	\N	2026-05-07 21:46:42.677+00	2026-05-07 21:46:42.677+00	\N
optval_01KR020EQ99NXD0V4GZ2H264K0	Black Cherry Peach	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQ9CAEXXSX6454C73M6	Blue Raz Gush - Gush Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQ9977R49RT6ZZ2MTDJ	Blue Razz Ice	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQ9XV71DQGQ9GNCV9RN	Blueberry Punch - Punch Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQ9MJT24H9BSJHT19B3	Blueberry Watermelon	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQ9A9KT28XVXBYR3FZN	Cherry Strapple	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQA78DXGP8PK35SHNMP	Clear	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAC2Q65D0RE1YV1G8B	Clear Diamond	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQA6SD7G5F8VBD7H8RN	Clear Sapphire	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.352+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAMZKWZWGMSCHNZHA7	Fire & Ice	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAYYK7YT2JA6Y75B05	Frozen Banana	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQA07QYVS9V10F3YT13	Frozen Cherry Apple	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAKEYWKHYZ1P5Y1G66	Frozen Dragonfruit Lemon	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQA7H2GQ0YCNYYPA4XZ	Frozen Juicy Strawberry	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAJV36XT5MS0EW4W0W	Frozen Raspberry Watermelon	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQDP4T5S78A4CP7E9BR	Bangin Sour Berries	opt_01KR020EQDDKDCR4XB40RDMGTP	\N	2026-05-07 01:49:32.786+00	2026-05-07 02:28:00.122+00	2026-05-07 02:28:00.112+00
optval_01KR020EQD3VW6ZGPC4MFMQ3QZ	Blueberry Watermelon	opt_01KR020EQDDKDCR4XB40RDMGTP	\N	2026-05-07 01:49:32.786+00	2026-05-07 02:28:00.122+00	2026-05-07 02:28:00.112+00
optval_01KR020EQDA355H3D11WB434WQ	New York Mint	opt_01KR020EQDDKDCR4XB40RDMGTP	\N	2026-05-07 01:49:32.786+00	2026-05-07 02:28:00.122+00	2026-05-07 02:28:00.112+00
optval_01KR020EQDV6HFCKNJS339RHND	Razzle Dazzle	opt_01KR020EQDDKDCR4XB40RDMGTP	\N	2026-05-07 01:49:32.786+00	2026-05-07 02:28:00.122+00	2026-05-07 02:28:00.112+00
optval_01KR020EQDJ8VX3MGNA04AQRS3	Strawberry Burst	opt_01KR020EQDDKDCR4XB40RDMGTP	\N	2026-05-07 01:49:32.786+00	2026-05-07 02:28:00.122+00	2026-05-07 02:28:00.112+00
optval_01KR020EQC8D8FXH3AYKV1YPGY	Mango Loco	opt_01KR020EQCRTP1X5AWJCGZECRS	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:28:02.999+00	2026-05-07 02:28:02.986+00
optval_01KR020EQCVWB56EKQ4TCX1K7G	Pink Lemonade Minty O's	opt_01KR020EQCRTP1X5AWJCGZECRS	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:28:02.999+00	2026-05-07 02:28:02.986+00
optval_01KR020EQA8AFG8XEQEEP2TYA1	Georgia Peach	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQA0VWAW81CY5NPPSN1	Hawaiian Punch - Punch Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQA9NN4S37NY911Y40T	Iced Blue Dragon	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAAMXBWFC7T91W5K0X	Miami Mint	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQA2M0EBDX7K9X7NKMK	New York Mint	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAHH65GBMQBBP7JQ1D	Night Crawler	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAN6Q135K6WE5T7YPS	Orange Pineapple Punch - Punch Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQAXHJKQ2ZGAE7A8YNX	Pink Lemonade Minty O's	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQB25K1VESW15YVEYAM	Rainbow Rain	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBHMRD4KX6EJ5PNPWG	Raspberry Limeade	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQB9SW26BNHP9ZFT4KE	Razzle Dazzle	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBM0H0KGQ41XB6DQVY	Sour Apple Ice	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBVSPS7F40ZR065FVR	Sour Raspberry Punch - Punch Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQB32FCWAQG3RZ4Z39C	Strawberry Burst	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBKSZNN7DXVFH85G8B	Strawberry Kiwi Pear	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBQ40A4WYN8121YN8M	Strawberry Orange Tang	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBMJMNZQTEDP2HAJD3	Strawberry Peach Gush - Gush Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBSDAHSV8TFJX4JP0S	Triple Berry Gush - Gush Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBSKBXFXYY5GNQRJ49	Triple Berry Punch - Punch Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBAN6X1JT4WQHRDP4R	Tropical Gush - Gush Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQB6WKFDZ6MEM7KKY5S	Watermelon Ice	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBK08EAP0KMQR6BYMH	White Grape Gush - Gush Edition	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR020EQBXMAE53GHBD7TG3XH	Wintergreen	opt_01KR020EQC48QGTZGFC3YSK837	\N	2026-05-07 01:49:32.785+00	2026-05-07 02:27:48.353+00	2026-05-07 02:27:48.3+00
optval_01KR2AAAVZWDXPE49Z4SQYCE0J	Blue Razz Ice	opt_01KR2AAAW0DCMVVPSEFMFZKFB1	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N
optval_01KR2AAAVZZ181RR2VDXMRN4Y9	Miami Mint	opt_01KR2AAAW0DCMVVPSEFMFZKFB1	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N
optval_01KR2AAAW0W42TR8YXZZPTH03T	Sour Apple Ice	opt_01KR2AAAW0DCMVVPSEFMFZKFB1	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N
optval_01KR2AAAW0WMQPR8AHEAWQ8NZX	Mango Loco	opt_01KR2AAAW0DCMVVPSEFMFZKFB1	\N	2026-05-07 22:53:13.988+00	2026-05-07 22:53:13.988+00	\N
\.


--
-- Data for Name: product_sales_channel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_sales_channel (product_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	prodsc_01KQPHSES9VXMF5YGWMWSE42PA	2026-05-03 09:12:56.359858+00	2026-05-03 18:16:54.609+00	2026-05-03 18:16:54.608+00
prod_01KQPHSERAFDQSTVMMVTCQJ5PC	sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	prodsc_01KQPHSES8JEQPG4J4TW406Z5H	2026-05-03 09:12:56.359858+00	2026-05-03 18:16:58.646+00	2026-05-03 18:16:58.646+00
prod_01KQPHSERBDBQMVHYR2D3TKKJY	sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	prodsc_01KQPHSES9G45CSQGKKANNDYZP	2026-05-03 09:12:56.359858+00	2026-05-03 18:17:02.284+00	2026-05-03 18:17:02.284+00
prod_01KQPHSERBX5WG7WWAYKMHKVE8	sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	prodsc_01KQPHSES96YYXK2TJ1PJQ3X5K	2026-05-03 09:12:56.359858+00	2026-05-03 18:17:06.186+00	2026-05-03 18:17:06.186+00
prod_01KQPJ7G1DRW1S8AMV6AP72KDB	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KQPJ7G27HJ9SW8X76NWVBMKT	2026-05-03 09:20:36.420428+00	2026-05-03 18:17:14.658+00	2026-05-03 18:17:14.658+00
prod_01KQPJ7G1DGCS8J83FXCGA00S8	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KQPJ7G26H5K7121N503VJ82S	2026-05-03 09:20:36.420428+00	2026-05-07 02:52:47.929+00	2026-05-07 02:52:47.924+00
prod_01KQPJ7G1DHT5KBQDV18K81HN8	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KQPJ7G26KTNB1NFDD5MJR02E	2026-05-03 09:20:36.420428+00	2026-05-07 02:53:04.691+00	2026-05-07 02:53:04.69+00
prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	prodsc_01KR06N1ZCBW3EPAXMAH52JZTB	2026-05-07 03:10:42.154574+00	2026-05-07 03:15:00.661+00	2026-05-07 03:15:00.66+00
prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KR06XCC05D9KWR2EDHV64WKX	2026-05-07 03:15:14.941973+00	2026-05-07 03:15:14.941973+00	\N
prod_01KR21MGDTXDF9B55TKB39PM04	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KR21MGFNZN80MFPWJ2W2N9R9	2026-05-07 20:21:30.226655+00	2026-05-07 20:21:30.226655+00	\N
prod_01KR26GH2MNKJP9X74ZMA3NPQV	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KR26GH79R7AHBXDYQJ5XX1T6	2026-05-07 21:46:42.791427+00	2026-05-07 21:46:42.791427+00	\N
prod_01KR2AAAVPRZ3VG53QESA2AWGN	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KR2AAAY0J3TCWQ77HADKNW81	2026-05-07 22:53:14.044949+00	2026-05-07 22:53:14.044949+00	\N
prod_01KR2CNPM96BND9CVPP0R3GJWD	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	prodsc_01KR2CNPNQ6ASNXT903WW6CG73	2026-05-07 23:34:23.668806+00	2026-05-07 23:34:23.668806+00	\N
\.


--
-- Data for Name: product_shipping_profile; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_shipping_profile (product_id, shipping_profile_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KQPHSESMQDMHP1FY2Y8EYJW3	2026-05-03 09:12:56.371199+00	2026-05-03 18:16:54.613+00	2026-05-03 18:16:54.613+00
prod_01KQPHSERAFDQSTVMMVTCQJ5PC	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KQPHSESK9DENFP6QWT2Y7HFD	2026-05-03 09:12:56.371199+00	2026-05-03 18:16:58.644+00	2026-05-03 18:16:58.644+00
prod_01KQPHSERBDBQMVHYR2D3TKKJY	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KQPHSESMRK6R5AGNVYET4ZW6	2026-05-03 09:12:56.371199+00	2026-05-03 18:17:02.286+00	2026-05-03 18:17:02.286+00
prod_01KQPHSERBX5WG7WWAYKMHKVE8	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KQPHSESMFX4043Z337W49FG9	2026-05-03 09:12:56.371199+00	2026-05-03 18:17:06.186+00	2026-05-03 18:17:06.185+00
prod_01KQPJ7G1DRW1S8AMV6AP72KDB	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KQPJ7G2GGQGB95KPM5ZGXWC0	2026-05-03 09:20:36.430336+00	2026-05-03 18:17:14.661+00	2026-05-03 18:17:14.661+00
prod_01KQPJ7G1DGCS8J83FXCGA00S8	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KQPJ7G2GT99TCRFPT7TVT9CD	2026-05-03 09:20:36.430336+00	2026-05-07 02:52:47.941+00	2026-05-07 02:52:47.94+00
prod_01KQPJ7G1DHT5KBQDV18K81HN8	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KQPJ7G2G3VJ6T7JPHJP6SQ5X	2026-05-03 09:20:36.430336+00	2026-05-07 02:53:04.687+00	2026-05-07 02:53:04.687+00
prod_01KR26GH2MNKJP9X74ZMA3NPQV	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KR26GH7YXZ93TM2K0BEBHDK5	2026-05-07 21:46:42.812427+00	2026-05-07 21:46:42.812427+00	\N
prod_01KR2AAAVPRZ3VG53QESA2AWGN	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KR2AAAYH4PMWXGRJYWY7W1ZC	2026-05-07 22:53:14.065157+00	2026-05-07 22:53:14.065157+00	\N
prod_01KR2CNPM96BND9CVPP0R3GJWD	sp_01KQPHSEFM77XP8JWGTBSQZPXB	prodsp_01KR2CNPP50BPM2E4MYSGYS8MG	2026-05-07 23:34:23.682932+00	2026-05-07 23:34:23.682932+00	\N
\.


--
-- Data for Name: product_tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_tag (id, value, metadata, created_at, updated_at, deleted_at, external_id) FROM stdin;
ptag_01KR22T3A8280VA50RVPTE3JSR	rechargeable	\N	2026-05-07 20:42:01.928+00	2026-05-07 20:42:01.928+00	\N	\N
ptag_01KR22VFHY803CEZ5CDPYZMBT4	disposable-vape	\N	2026-05-07 20:42:47.231+00	2026-05-07 20:42:47.231+00	\N	\N
ptag_01KR22WW9TM5D6HJXTMPN6SB2J	high-puff	\N	2026-05-07 20:43:33.051+00	2026-05-07 20:43:33.051+00	\N	\N
ptag_01KR22XMBH3W7P7PCKM0HK2WSQ	turbo-mode	\N	2026-05-07 20:43:57.682+00	2026-05-07 20:43:57.682+00	\N	\N
ptag_01KR22Y7BPA0D6GG6FJB58B84J	best-seller	\N	2026-05-07 20:44:17.142+00	2026-05-07 20:44:17.142+00	\N	\N
ptag_01KR2CGXZPRSBVN5JBJ6QP6M53	cones	\N	2026-05-07 23:31:47.319+00	2026-05-07 23:31:47.319+00	\N	\N
ptag_01KR2CHC4M9YDFB78NV8CQPW1V	paper	\N	2026-05-07 23:32:01.813+00	2026-05-07 23:32:01.813+00	\N	\N
ptag_01KR2CHSGYCRYPHXS71W4JES8J	smoking-accessory	\N	2026-05-07 23:32:15.518+00	2026-05-07 23:32:15.518+00	\N	\N
ptag_01KR2CJ2G7GJHVPQDCHNCFEDFA	king-size	\N	2026-05-07 23:32:24.712+00	2026-05-07 23:32:24.712+00	\N	\N
ptag_01KR2D89AK41CXPTYWS0AFVHWB	disposable-lighter	\N	2026-05-07 23:44:32.596+00	2026-05-07 23:44:32.596+00	\N	\N
ptag_01KR2D8N2BHM8C1P74NMDCF2TB	refillable-lighter	\N	2026-05-07 23:44:44.62+00	2026-05-07 23:44:44.62+00	\N	\N
ptag_01KR2D8YTN5FE303AHQC0CVD5Q	torch-lighter	\N	2026-05-07 23:44:54.614+00	2026-05-07 23:44:54.614+00	\N	\N
ptag_01KR2D98NWQT1RRVGJ2HDVY3ZM	classic-lighter	\N	2026-05-07 23:45:04.704+00	2026-05-07 23:45:04.704+00	\N	\N
ptag_01KR2D9NA4GQQVFB33SQBKY69Q	bic	\N	2026-05-07 23:45:17.637+00	2026-05-07 23:45:17.637+00	\N	\N
\.


--
-- Data for Name: product_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_tags (product_id, product_tag_id) FROM stdin;
prod_01KR21MGDTXDF9B55TKB39PM04	ptag_01KR22T3A8280VA50RVPTE3JSR
prod_01KR21MGDTXDF9B55TKB39PM04	ptag_01KR22VFHY803CEZ5CDPYZMBT4
prod_01KR21MGDTXDF9B55TKB39PM04	ptag_01KR22WW9TM5D6HJXTMPN6SB2J
prod_01KR21MGDTXDF9B55TKB39PM04	ptag_01KR22XMBH3W7P7PCKM0HK2WSQ
prod_01KR21MGDTXDF9B55TKB39PM04	ptag_01KR22Y7BPA0D6GG6FJB58B84J
prod_01KR26GH2MNKJP9X74ZMA3NPQV	ptag_01KR22VFHY803CEZ5CDPYZMBT4
prod_01KR26GH2MNKJP9X74ZMA3NPQV	ptag_01KR22T3A8280VA50RVPTE3JSR
prod_01KR26GH2MNKJP9X74ZMA3NPQV	ptag_01KR22Y7BPA0D6GG6FJB58B84J
prod_01KR2AAAVPRZ3VG53QESA2AWGN	ptag_01KR22VFHY803CEZ5CDPYZMBT4
prod_01KR2AAAVPRZ3VG53QESA2AWGN	ptag_01KR22T3A8280VA50RVPTE3JSR
prod_01KR2AAAVPRZ3VG53QESA2AWGN	ptag_01KR22WW9TM5D6HJXTMPN6SB2J
prod_01KR2AAAVPRZ3VG53QESA2AWGN	ptag_01KR22Y7BPA0D6GG6FJB58B84J
prod_01KR2CNPM96BND9CVPP0R3GJWD	ptag_01KR2CGXZPRSBVN5JBJ6QP6M53
prod_01KR2CNPM96BND9CVPP0R3GJWD	ptag_01KR2CHC4M9YDFB78NV8CQPW1V
prod_01KR2CNPM96BND9CVPP0R3GJWD	ptag_01KR2CHSGYCRYPHXS71W4JES8J
prod_01KR2CNPM96BND9CVPP0R3GJWD	ptag_01KR2CJ2G7GJHVPQDCHNCFEDFA
\.


--
-- Data for Name: product_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_type (id, value, metadata, created_at, updated_at, deleted_at, external_id) FROM stdin;
ptyp_01KR06YYR7V5FX6JBNSSGQBC9V	Disposable Vapes	\N	2026-05-07 03:16:06.537+00	2026-05-07 20:46:11.503+00	\N	\N
ptyp_01KR2CF0RNCNBY88W8ZQ1S6NBR	Cones	\N	2026-05-07 23:30:44.63+00	2026-05-07 23:30:44.63+00	\N	\N
ptyp_01KR2D3FTEKWMHTEFKBYSJ9BJ7	Disposable Lighter	\N	2026-05-07 23:41:55.406+00	2026-05-07 23:41:55.406+00	\N	\N
\.


--
-- Data for Name: product_variant; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant (id, title, sku, barcode, ean, upc, allow_backorder, manage_inventory, hs_code, origin_country, mid_code, material, weight, length, height, width, metadata, variant_rank, product_id, created_at, updated_at, deleted_at, thumbnail) FROM stdin;
variant_01KQPJ7G3BEX6624X89GF6HQDF	Default	LOST-MARY-MT35000-TURBO	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPJ7G1DGCS8J83FXCGA00S8	2026-05-03 09:20:36.46+00	2026-05-07 02:52:47.914+00	2026-05-07 02:52:47.892+00	\N
variant_01KQPJ7G3BQ37TBEF2A3GT3WZW	Blue Raz Gush	RAZ-LTX-25000-BLUE-RAZ-GUSH	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPJ7G1DHT5KBQDV18K81HN8	2026-05-03 09:20:36.459+00	2026-05-07 02:53:04.702+00	2026-05-07 02:53:04.682+00	\N
variant_01KR06N20GQ28JY1DK4ZFQ6G8B	Miami Mint	RTN9000-MM	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	2026-05-07 03:10:42.192+00	2026-05-07 03:10:42.192+00	\N	\N
variant_01KR06N20GZ7RYQYEJFGDPYP3W	Night Crawler	RTN9000-NC	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	2026-05-07 03:10:42.193+00	2026-05-07 03:10:42.193+00	\N	\N
variant_01KR06N20G0FF5TVPPX3P9SMQ0	Blue Raz Ice	RTN9000-BR	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	2026-05-07 03:10:42.193+00	2026-05-07 03:10:42.193+00	\N	\N
variant_01KR06N20GCBC4DDWRZHY3KA3G	Strawberry Ice	RTN9000-SI	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	prod_01KR06N1Y1PW3M72R7TQ7ZCMFZ	2026-05-07 03:10:42.193+00	2026-05-07 03:10:42.193+00	\N	\N
variant_01KR252HHWRY9NQKMDGDNBXY75	Watermelon Ice	LMMT35KT-WI	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR21MGDTXDF9B55TKB39PM04	2026-05-07 21:21:35.804+00	2026-05-07 21:21:35.804+00	\N	\N
variant_01KR2CNPQ1PSQ1DECMG56FMG2Q	Default variant	RWKC-3PK	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR2CNPM96BND9CVPP0R3GJWD	2026-05-07 23:34:23.713+00	2026-05-07 23:34:23.713+00	\N	\N
variant_01KQPHSETC3J25MS5R17WG7YJ7	S	SWEATSHIRT-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	2026-05-03 09:12:56.398+00	2026-05-03 18:16:54.618+00	2026-05-03 18:16:54.606+00	\N
variant_01KQPHSETC3FKD990GD5A020AY	M	SWEATSHIRT-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	2026-05-03 09:12:56.398+00	2026-05-03 18:16:54.619+00	2026-05-03 18:16:54.606+00	\N
variant_01KQPHSETC1B0H4XYH05YHD1AZ	L	SWEATSHIRT-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	2026-05-03 09:12:56.398+00	2026-05-03 18:16:54.619+00	2026-05-03 18:16:54.606+00	\N
variant_01KQPHSETCDCFDE957NY4DM4X4	XL	SWEATSHIRT-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBZJ3HA9Z7K6ZPWJT9	2026-05-03 09:12:56.398+00	2026-05-03 18:16:54.619+00	2026-05-03 18:16:54.606+00	\N
variant_01KQPHSETB7R9QF7PDKXBGCAFH	S / Black	SHIRT-S-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.397+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETB8ESJBWT0SN7Q06WT	S / White	SHIRT-S-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.397+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETBT3C6BGKZN2R71CGB	M / Black	SHIRT-M-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.398+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETB3W7VKWHH89Q1YWFZ	M / White	SHIRT-M-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.398+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETBXX0P8VQGGHNRK0KC	L / Black	SHIRT-L-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.398+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETBRGKPJJFKX8SYK79R	L / White	SHIRT-L-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.398+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETBR16VG1NEQ6WGJ3D4	XL / Black	SHIRT-XL-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.398+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETB4DNSMFPVNTA2VXNH	XL / White	SHIRT-XL-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERAFDQSTVMMVTCQJ5PC	2026-05-03 09:12:56.398+00	2026-05-03 18:16:58.655+00	2026-05-03 18:16:58.643+00	\N
variant_01KQPHSETCK9GHVWRZWJ4P79A8	S	SWEATPANTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBDBQMVHYR2D3TKKJY	2026-05-03 09:12:56.398+00	2026-05-03 18:17:02.293+00	2026-05-03 18:17:02.283+00	\N
variant_01KQPHSETC26DE8CGZJ86MK5RH	M	SWEATPANTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBDBQMVHYR2D3TKKJY	2026-05-03 09:12:56.398+00	2026-05-03 18:17:02.293+00	2026-05-03 18:17:02.283+00	\N
variant_01KQPHSETC487HRT8YPKYBMTMN	L	SWEATPANTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBDBQMVHYR2D3TKKJY	2026-05-03 09:12:56.398+00	2026-05-03 18:17:02.293+00	2026-05-03 18:17:02.283+00	\N
variant_01KQPHSETC7K2VJ6KVE7WF7BAQ	XL	SWEATPANTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBDBQMVHYR2D3TKKJY	2026-05-03 09:12:56.398+00	2026-05-03 18:17:02.293+00	2026-05-03 18:17:02.283+00	\N
variant_01KQPHSETDAS7C3AP1M5JGX2FR	S	SHORTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBX5WG7WWAYKMHKVE8	2026-05-03 09:12:56.398+00	2026-05-03 18:17:06.195+00	2026-05-03 18:17:06.185+00	\N
variant_01KQPHSETDBPSXADAAAKC2NZNT	M	SHORTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBX5WG7WWAYKMHKVE8	2026-05-03 09:12:56.398+00	2026-05-03 18:17:06.195+00	2026-05-03 18:17:06.185+00	\N
variant_01KQPHSETDPER2A94MF1BHQSDY	L	SHORTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBX5WG7WWAYKMHKVE8	2026-05-03 09:12:56.398+00	2026-05-03 18:17:06.195+00	2026-05-03 18:17:06.185+00	\N
variant_01KQPHSETDZY4N3Q476PANCSTE	XL	SHORTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPHSERBX5WG7WWAYKMHKVE8	2026-05-03 09:12:56.398+00	2026-05-03 18:17:06.195+00	2026-05-03 18:17:06.185+00	\N
variant_01KQPJ7G3B6ABC5E7ZGZPBQRNY	Default	WAVE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KQPJ7G1DRW1S8AMV6AP72KDB	2026-05-03 09:20:36.46+00	2026-05-03 18:17:14.668+00	2026-05-03 18:17:14.659+00	\N
variant_01KR020ET9DSHWMWF9MHJZEGE0	Miami Mint	gvp-raz-vue-50k-pod-1pk-miami-mint	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETAE2NK0JNBE83BVJBJ	Polar Ice	gvp-raz-vue-50k-pod-1pk-polar-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETATPQ5VS6SJHQ4NF7N	Triple Berry Lime	gvp-raz-vue-50k-pod-1pk-triple-berry-lime	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETAG2WYH6202KC57DC0	Blue Raz Ice	gvp-raz-vue-50k-pod-1pk-blue-raz-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETA3V5ARXKJJEV7NR5G	Hawaiian Punch	gvp-raz-vue-50k-pod-1pk-hawaiian-punch	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETAZZFE5SSQTN411K4M	Pineapple MTN Dew	gvp-raz-vue-50k-pod-1pk-pineapple-mtn-dew	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETAD2QW5AVFZK64AEFV	Sour Apple Ice	gvp-raz-vue-50k-pod-1pk-sour-apple-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETAZEVC6V5ZAXABY84X	Strawberry Blast	gvp-raz-vue-50k-pod-1pk-strawberry-blast	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR21MGGZXFD0G0MTF1TM9MCC	Baja Splash, Berry Burst, Blue Razz Ice, Blackberry Blueberry, Black Mint, Black Razz Lemon	LMMT35KT	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	{"brand": "Lost Mary", "spec_puffs": "Up to 35,000 regular / 20,000 turbo", "spec_capacity": "18mL", "spec_nicotine": "50mg"}	0	prod_01KR21MGDTXDF9B55TKB39PM04	2026-05-07 20:21:30.271+00	2026-05-07 21:19:13.037+00	2026-05-07 21:19:13.036+00	\N
variant_01KR2535GWTAV92J6P4DTNK1SF	Tobacco	LMMT35KT-TB	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR21MGDTXDF9B55TKB39PM04	2026-05-07 21:21:56.252+00	2026-05-07 21:21:56.252+00	\N	\N
variant_01KR020ETDD8V2N3WJXYWGK96S	Bangin Sour Berries	gvp-raz-ltx-25k-disp-1pk-bangin-sour-berries	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETDGSYR7NP8XFN86HAW	Black Cherry Peach	gvp-raz-ltx-25k-disp-1pk-black-cherry-peach	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETBA1J0CH1QH8SQTKCE	Blue Raz Ice	gvp-raz-vue-kit-50k-disp-blue-raz-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.883+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETBN54J2Z2GGN67FYCA	Hawaiian Punch	gvp-raz-vue-kit-50k-disp-hawaiian-punch	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.883+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETBRG52DRX8FVHXTYTT	Miami Mint	gvp-raz-vue-kit-50k-disp-miami-mint	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.883+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETB08A100KXZA69S899	Pineapple MTN Dew	gvp-raz-vue-kit-50k-disp-pineapple-mtn-dew	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.883+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETCM2P3SHKM6QCX7F0R	Polar Ice	gvp-raz-vue-kit-50k-disp-polar-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.883+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETCD2V6TWDTH237WWXS	Sour Apple Ice	gvp-raz-vue-kit-50k-disp-sour-apple-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.883+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETC9YTNQ2R389GGK632	Strawberry Blast	gvp-raz-vue-kit-50k-disp-strawberry-blast	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.884+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETCMNY3XK6FWPZMV80P	Triple Berry Lime	gvp-raz-vue-kit-50k-disp-triple-berry-lime	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.884+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETCF0XK6CXHDZF4VDG6	Watermelon Ice	gvp-raz-vue-kit-50k-disp-watermelon-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.884+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETCSZY4HANHH4A1W8EH	White Gummy	gvp-raz-vue-kit-50k-disp-white-gummy	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNHR59Q1C2FZ7S4QH8	2026-05-07 01:49:32.884+00	2026-05-07 02:27:50.178+00	2026-05-07 02:27:50.17+00	\N
variant_01KR020ETC29TD5VQKK84GBX88	Code Blue	gvp-raz-rx-50k-disp-code-blue	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNMAV2M74GW005XGRD	2026-05-07 01:49:32.884+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00	\N
variant_01KR020ETCWNVY9HHJZC3H5ZBW	Code Green	gvp-raz-rx-50k-disp-code-green	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNMAV2M74GW005XGRD	2026-05-07 01:49:32.884+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00	\N
variant_01KR020ETCAAGAQ6H6AY9VKVFW	Code Pink	gvp-raz-rx-50k-disp-code-pink	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNMAV2M74GW005XGRD	2026-05-07 01:49:32.884+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00	\N
variant_01KR020ETC2F8A2W70G2X4838T	Code Red	gvp-raz-rx-50k-disp-code-red	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNMAV2M74GW005XGRD	2026-05-07 01:49:32.884+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00	\N
variant_01KR020ETCEVTQ2XRXJ7F3E1WG	Code White	gvp-raz-rx-50k-disp-code-white	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNMAV2M74GW005XGRD	2026-05-07 01:49:32.884+00	2026-05-07 02:27:53.855+00	2026-05-07 02:27:53.846+00	\N
variant_01KR250JCN0DS48VEGZKF0S8KS	Blue Razz Ice	LMMT35KT-BR	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR21MGDTXDF9B55TKB39PM04	2026-05-07 21:20:31.125+00	2026-05-07 21:20:31.125+00	\N	\N
variant_01KR26GH9FHCS47X4NKJ2100PV	Miami Mint	GBP15K-MM	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR26GH2MNKJP9X74ZMA3NPQV	2026-05-07 21:46:42.865+00	2026-05-07 21:46:42.865+00	\N	\N
variant_01KR26GH9F4XTCVJ4RM405AZ6W	Blue Razz Ice	GBP15K-BR	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	prod_01KR26GH2MNKJP9X74ZMA3NPQV	2026-05-07 21:46:42.865+00	2026-05-07 21:46:42.865+00	\N	\N
variant_01KR26GH9GB74FMJSRCME1J1Z7	Berry Bliss	GBP15K-BB	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	prod_01KR26GH2MNKJP9X74ZMA3NPQV	2026-05-07 21:46:42.865+00	2026-05-07 21:46:42.865+00	\N	\N
variant_01KR26GH9G01H235TN94XZ14T7	Blueberry Watermelon	GBP15K-BW	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	prod_01KR26GH2MNKJP9X74ZMA3NPQV	2026-05-07 21:46:42.865+00	2026-05-07 21:46:42.865+00	\N	\N
variant_01KR020ETB263T794NKZ5W5HKF	Watermelon Ice	gvp-raz-vue-50k-pod-1pk-watermelon-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETBVWFPKTJQHSJ52Z49	White Gummy	gvp-raz-vue-50k-pod-1pk-white-gummy	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPM5X42055YHXD2VB8M	2026-05-07 01:49:32.883+00	2026-05-07 02:27:45.325+00	2026-05-07 02:27:45.284+00	\N
variant_01KR020ETDNSSHCTW6T1A07TFD	Blue Raz Gush - Gush Edition	gvp-raz-ltx-25k-disp-1pk-blue-raz-gush	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETDB9M8H0W5SNDNEY3P	Blue Razz Ice	gvp-raz-ltx-25k-disp-1pk-blue-razz-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETDCVARXQJDY4CSM9ER	Blueberry Punch - Punch Edition	gvp-raz-ltx-25k-disp-1pk-blueberry-punch	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETDAMHG09KADDC98CJ4	Blueberry Watermelon	gvp-raz-ltx-25k-disp-1pk-blueberry-watermelon	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETD9PGVQFM456TF4CMG	Cherry Strapple	gvp-raz-ltx-25k-disp-1pk-cherry-strapple	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETD6BYYR52KBBCWYCGV	Clear	gvp-raz-ltx-25k-disp-1pk-clear	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEKR37JNRZPRS20EP6	Clear Diamond	gvp-raz-ltx-25k-disp-1pk-clear-diamond	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETE77BQQ2VG9ESQNYY6	Clear Sapphire	gvp-raz-ltx-25k-disp-1pk-clear-sapphire	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEHXZDC4A1ASE24THB	Fire & Ice	gvp-raz-ltx-25k-disp-1pk-fire-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEAX2850MZV7J07B87	Frozen Banana	gvp-raz-ltx-25k-disp-1pk-frozen-banana	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETE51ZYVD78NWEZPACD	Frozen Cherry Apple	gvp-raz-ltx-25k-disp-1pk-frozen-cherry-apple	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEMDGPHPA7B3MSPK6N	Frozen Dragonfruit Lemon	gvp-raz-ltx-25k-disp-1pk-frozen-dragonfruit-lemon	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEW9N6AQNQKYPYZVJN	Frozen Juicy Strawberry	gvp-raz-ltx-25k-disp-1pk-frozen-juicy-strawberry	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEHY12KS15A0VKWAKW	Frozen Raspberry Watermelon	gvp-raz-ltx-25k-disp-1pk-frozen-raspberry-watermelon	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETECETWVWK4K8SV81QB	Georgia Peach	gvp-raz-ltx-25k-disp-1pk-georgia-peach	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEA590J77TANRTPMK8	Hawaiian Punch - Punch Edition	gvp-raz-ltx-25k-disp-1pk-hawaiian-punch	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETEV73J8Z3ZCGKZNHNQ	Iced Blue Dragon	gvp-raz-ltx-25k-disp-1pk-iced-blue-dragon	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.324+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFYVVSCCM53BCKF1BT	Miami Mint	gvp-raz-ltx-25k-disp-1pk-miami-mint	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFG6SFD5V30GJ9ZRRC	New York Mint	gvp-raz-ltx-25k-disp-1pk-new-york-mint	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETF19P521JJZHZQESM5	Night Crawler	gvp-raz-ltx-25k-disp-1pk-night-crawler	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETHMB8SQ29ADKGD52V6	Bangin Sour Berries	gvp-raz-ltx-25k-0nic-disp-1pk-bangin-sour-berries	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNN8K97EZMCJFTC5R2	2026-05-07 01:49:32.885+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00	\N
variant_01KR020ETHSEYS8PZZEM45KAT6	Blueberry Watermelon	gvp-raz-ltx-25k-0nic-disp-1pk-blueberry-watermelon	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNN8K97EZMCJFTC5R2	2026-05-07 01:49:32.885+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00	\N
variant_01KR020ETHADYH6R4ZRH0RJRJB	New York Mint	gvp-raz-ltx-25k-0nic-disp-1pk-new-york-mint	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNN8K97EZMCJFTC5R2	2026-05-07 01:49:32.885+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00	\N
variant_01KR020ETH0T07AXYY7TVZZPXB	Razzle Dazzle	gvp-raz-ltx-25k-0nic-disp-1pk-razzle-dazzle	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNN8K97EZMCJFTC5R2	2026-05-07 01:49:32.885+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00	\N
variant_01KR020ETHACSVTSE4AB5R606E	Strawberry Burst	gvp-raz-ltx-25k-0nic-disp-1pk-strawberry-burst	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNN8K97EZMCJFTC5R2	2026-05-07 01:49:32.885+00	2026-05-07 02:28:00.117+00	2026-05-07 02:28:00.112+00	\N
variant_01KR020ETG84KBNSAHXQVCX0FR	Mango Loco	gvp-raz-dc25000-disp-1pk-mango-loco	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNY1RZMM5WJNCQ66HB	2026-05-07 01:49:32.885+00	2026-05-07 02:28:02.994+00	2026-05-07 02:28:02.986+00	\N
variant_01KR020ETHJ6QF5WWBNT7S8C74	Pink Lemonade Minty O's	gvp-raz-dc25000-disp-1pk-pink-lemonade-minty-os	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPNY1RZMM5WJNCQ66HB	2026-05-07 01:49:32.885+00	2026-05-07 02:28:02.994+00	2026-05-07 02:28:02.986+00	\N
variant_01KR020ETF9P17MDFA45PNBTTG	Orange Pineapple Punch - Punch Edition	gvp-raz-ltx-25k-disp-1pk-orange-pineapple-punch	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFVX54VD7BD9HH5WZ3	Pink Lemonade Minty O's	gvp-raz-ltx-25k-disp-1pk-pink-lemonade-minty-os	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFTYMEQ5RQP25CQCS4	Rainbow Rain	gvp-raz-ltx-25k-disp-1pk-rainbow-rain	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFCN0FHCG3298G1EEA	Raspberry Limeade	gvp-raz-ltx-25k-disp-1pk-raspberry-limeade	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFVW3KEDXV93FXG4VS	Razzle Dazzle	gvp-raz-ltx-25k-disp-1pk-razzle-dazzle	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFMPKXV00VEGYYAHBQ	Sour Apple Ice	gvp-raz-ltx-25k-disp-1pk-sour-apple-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFTG8884AXYCRR3CHD	Sour Raspberry Punch - Punch Edition	gvp-raz-ltx-25k-disp-1pk-sour-raspberry-punch	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETFQHSZNVECZ3B34M5R	Strawberry Burst	gvp-raz-ltx-25k-disp-1pk-strawberry-burst	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGEV7CP486YHF2KM9A	Strawberry Kiwi Pear	gvp-raz-ltx-25k-disp-1pk-strawberry-kiwi-pear	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGP6D4NF692QN98Q17	Strawberry Orange Tang	gvp-raz-ltx-25k-disp-1pk-strawberry-orange-tang	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGPJBYN7XG7AM4N9EQ	Strawberry Peach Gush - Gush Edition	gvp-raz-ltx-25k-disp-1pk-strawberry-peach-gush	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGNEN24BV00RNZMNHB	Triple Berry Gush - Gush Edition	gvp-raz-ltx-25k-disp-1pk-triple-berry-gush	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGVPA9384N95T0S3V0	Triple Berry Punch - Punch Edition	gvp-raz-ltx-25k-disp-1pk-triple-berry-punch	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETG3W7VBM411CNNEM95	Tropical Gush - Gush Edition	gvp-raz-ltx-25k-disp-1pk-tropical-gush	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGXJ0ET0A98V9H7PGV	Watermelon Ice	gvp-raz-ltx-25k-disp-1pk-watermelon-ice	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.884+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGY2PKBHRG2SVGA9HJ	White Grape Gush - Gush Edition	gvp-raz-ltx-25k-disp-1pk-white-grape-gush	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.885+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR020ETGVS0AN1Y68D03XV2J	Wintergreen	gvp-raz-ltx-25k-disp-1pk-wintergreen	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR020EPN1524QFK6KV5KQFT5	2026-05-07 01:49:32.885+00	2026-05-07 02:27:48.325+00	2026-05-07 02:27:48.3+00	\N
variant_01KR251F0B3N25NR865YFMNSG6	Miami Mint	LMMT35KT-MM	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR21MGDTXDF9B55TKB39PM04	2026-05-07 21:21:00.427+00	2026-05-07 21:21:00.427+00	\N	\N
variant_01KR2AAAZKNZPEQ4693H2RM8Z5	Blue Razz Ice	RLTX25K-BR	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KR2AAAVPRZ3VG53QESA2AWGN	2026-05-07 22:53:14.1+00	2026-05-07 22:53:14.1+00	\N	\N
variant_01KR2AAAZKNST690FATR7E6A2R	Miami Mint	RLTX25K-MM	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	prod_01KR2AAAVPRZ3VG53QESA2AWGN	2026-05-07 22:53:14.1+00	2026-05-07 22:53:14.1+00	\N	\N
variant_01KR2AAAZM5K2Y3TBDHBR6QDDF	Sour Apple Ice	RLTX25K-SA	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	prod_01KR2AAAVPRZ3VG53QESA2AWGN	2026-05-07 22:53:14.1+00	2026-05-07 22:53:14.1+00	\N	\N
variant_01KR2AAAZM3V4X6SRT2RNP7K35	Mango Loco	RLTX25K-ML	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	prod_01KR2AAAVPRZ3VG53QESA2AWGN	2026-05-07 22:53:14.1+00	2026-05-07 22:53:14.1+00	\N	\N
\.


--
-- Data for Name: product_variant_inventory_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_inventory_item (variant_id, inventory_item_id, id, required_quantity, created_at, updated_at, deleted_at) FROM stdin;
variant_01KQPJ7G3BEX6624X89GF6HQDF	iitem_01KQPJ7G3T6SMTKBMT6E9K88J8	pvitem_01KQPJ7G48QF6E2BFDTRPQDP7B	1	2026-05-03 09:20:36.485641+00	2026-05-07 02:52:47.867+00	2026-05-07 02:52:47.866+00
variant_01KQPJ7G3BQ37TBEF2A3GT3WZW	iitem_01KQPJ7G3TM1X2BWNQQMWBSFJ6	pvitem_01KQPJ7G47NEAYFHMPYZAR9SF6	1	2026-05-03 09:20:36.485641+00	2026-05-07 02:53:04.661+00	2026-05-07 02:53:04.66+00
variant_01KQPHSETC3J25MS5R17WG7YJ7	iitem_01KQPHSEV9334Y8ESSHA7SXXRD	pvitem_01KQPHSEVWTQVGZRZJCS0BPPE3	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:54.594+00	2026-05-03 18:16:54.593+00
variant_01KQPHSETC3FKD990GD5A020AY	iitem_01KQPHSEV9SQ2VNMPE9KA02HTZ	pvitem_01KQPHSEVWFBD3WVX9GW3AJ45E	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:54.594+00	2026-05-03 18:16:54.593+00
variant_01KQPHSETC1B0H4XYH05YHD1AZ	iitem_01KQPHSEV9FP21RZAFKT5WDN4F	pvitem_01KQPHSEVW4PMBP55ZYTR830TS	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:54.594+00	2026-05-03 18:16:54.593+00
variant_01KQPHSETCDCFDE957NY4DM4X4	iitem_01KQPHSEV9RQMXKVFG92C216BK	pvitem_01KQPHSEVWNRTEKZ3W7C1YYV04	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:54.594+00	2026-05-03 18:16:54.593+00
variant_01KQPHSETB7R9QF7PDKXBGCAFH	iitem_01KQPHSEV834S9D3TH81TRV6MC	pvitem_01KQPHSEVVTV1659SAVNWQ5MNV	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETB8ESJBWT0SN7Q06WT	iitem_01KQPHSEV8R9EF3J2GVN13TGHK	pvitem_01KQPHSEVW592JQM8YCB3351PM	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETBT3C6BGKZN2R71CGB	iitem_01KQPHSEV8GT1Q2TXX78H1CYX2	pvitem_01KQPHSEVW7Z2B96FNNRB8HPBG	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETB3W7VKWHH89Q1YWFZ	iitem_01KQPHSEV8RWRZ5HV2BTRX70VE	pvitem_01KQPHSEVWKAM7EHG9VTN1T6AQ	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETBXX0P8VQGGHNRK0KC	iitem_01KQPHSEV8A0Z8NS94H30H8N8V	pvitem_01KQPHSEVWTKGZ1K684KC47THJ	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETBRGKPJJFKX8SYK79R	iitem_01KQPHSEV87C9WEWRNW04EDFWY	pvitem_01KQPHSEVW4JBTEP6WZYRXG8ZZ	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETBR16VG1NEQ6WGJ3D4	iitem_01KQPHSEV8BCTFY003EWYA5V6Q	pvitem_01KQPHSEVWK3AZBHB1FE53J4ZW	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETB4DNSMFPVNTA2VXNH	iitem_01KQPHSEV829RNGRSJCDZYKNVN	pvitem_01KQPHSEVWNMX44B7B34DAW3KC	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:16:58.634+00	2026-05-03 18:16:58.634+00
variant_01KQPHSETCK9GHVWRZWJ4P79A8	iitem_01KQPHSEV9MSD6Z98ENR76MDV8	pvitem_01KQPHSEVW441Y3MSR2D5D7HJG	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:02.274+00	2026-05-03 18:17:02.273+00
variant_01KQPHSETC26DE8CGZJ86MK5RH	iitem_01KQPHSEV9J6F34RQSKHCTGCMN	pvitem_01KQPHSEVW5D9W8KJBEEJ3EQJY	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:02.274+00	2026-05-03 18:17:02.273+00
variant_01KQPHSETC487HRT8YPKYBMTMN	iitem_01KQPHSEV90GMZFB3PM4AAYBNS	pvitem_01KQPHSEVWQ10ZPDGBTZCQXMZ0	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:02.274+00	2026-05-03 18:17:02.273+00
variant_01KQPHSETC7K2VJ6KVE7WF7BAQ	iitem_01KQPHSEV9Z2WA4T8ANZZKG7RB	pvitem_01KQPHSEVXSS0J09XJCCF4E1T6	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:02.274+00	2026-05-03 18:17:02.273+00
variant_01KQPHSETDAS7C3AP1M5JGX2FR	iitem_01KQPHSEV9NP942J4PA63DXQWG	pvitem_01KQPHSEVXV3094VJD0B0Y3TBX	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:06.175+00	2026-05-03 18:17:06.175+00
variant_01KQPHSETDBPSXADAAAKC2NZNT	iitem_01KQPHSEV965XEBDNEJBX4YWGA	pvitem_01KQPHSEVX3GHMVSXSXVNW3902	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:06.175+00	2026-05-03 18:17:06.175+00
variant_01KQPHSETDPER2A94MF1BHQSDY	iitem_01KQPHSEV9YKKA19T4RG6XD8J3	pvitem_01KQPHSEVXCP3MF7084529HGWQ	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:06.175+00	2026-05-03 18:17:06.175+00
variant_01KQPHSETDZY4N3Q476PANCSTE	iitem_01KQPHSEVADJ0C65PKQTQDBMS8	pvitem_01KQPHSEVXHNAGYX3A13W8P090	1	2026-05-03 09:12:56.442807+00	2026-05-03 18:17:06.175+00	2026-05-03 18:17:06.175+00
variant_01KQPJ7G3B6ABC5E7ZGZPBQRNY	iitem_01KQPJ7G3TWE98KMNXAC7J84DW	pvitem_01KQPJ7G48RV4DP29NB3VD36CD	1	2026-05-03 09:20:36.485641+00	2026-05-03 18:17:14.651+00	2026-05-03 18:17:14.65+00
variant_01KR020ET9DSHWMWF9MHJZEGE0	iitem_01KR020EX3KMSJ7R8F2D2FEJGE	pvitem_01KR020EYNV3K4ZG4M9R346E2Y	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.257+00	2026-05-07 02:27:45.256+00
variant_01KR020ETAE2NK0JNBE83BVJBJ	iitem_01KR020EX4BPRBR1XA58PZSGJB	pvitem_01KR020EYPRZGW35ADE2MFKTHQ	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.257+00	2026-05-07 02:27:45.256+00
variant_01KR020ETATPQ5VS6SJHQ4NF7N	iitem_01KR020EX49FZ81Q3RGCPSWQWA	pvitem_01KR020EYP8JENBGZTEE9FA7PV	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.257+00	2026-05-07 02:27:45.256+00
variant_01KR020ETAG2WYH6202KC57DC0	iitem_01KR020EX40PGJ082H30QXAJNC	pvitem_01KR020EYP4N10YDN610YPYD66	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.257+00	2026-05-07 02:27:45.256+00
variant_01KR020ETA3V5ARXKJJEV7NR5G	iitem_01KR020EX41E2ACVWSM7XR6K06	pvitem_01KR020EYPRDQ55CZ4HKMQNK6B	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.257+00	2026-05-07 02:27:45.256+00
variant_01KR020ETAZZFE5SSQTN411K4M	iitem_01KR020EX4KM97E2A21MBFDHF9	pvitem_01KR020EYQVWFPXEYEB1SM3KHM	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.257+00	2026-05-07 02:27:45.256+00
variant_01KR020ETAD2QW5AVFZK64AEFV	iitem_01KR020EX4VCWFYVA27GSC3SHR	pvitem_01KR020EYQ49AY5AHH0323CNK5	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.258+00	2026-05-07 02:27:45.256+00
variant_01KR020ETDD8V2N3WJXYWGK96S	iitem_01KR020EX6N6WRZV3MKBMCDCJ8	pvitem_01KR020EYR08R19GJQJM85RRQT	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETDGSYR7NP8XFN86HAW	iitem_01KR020EX6NZXCMPVZ9QQG8DKJ	pvitem_01KR020EYSXPS2HDJWVKVJKP0D	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETDNSSHCTW6T1A07TFD	iitem_01KR020EX7CDNTFBDAJ1XYVM3J	pvitem_01KR020EYSTPASRBHG0AVSS6HE	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETBA1J0CH1QH8SQTKCE	iitem_01KR020EX5TAX9Q75VA96YD2ST	pvitem_01KR020EYQS8SXVC8H248FV6C2	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETBN54J2Z2GGN67FYCA	iitem_01KR020EX5KFSBJ2SSAG466BXX	pvitem_01KR020EYQNMKD7W1CQ0HZST42	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETBRG52DRX8FVHXTYTT	iitem_01KR020EX562KK8CPGHDYQHN44	pvitem_01KR020EYQ4WNBPYBSASBZ9MHH	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETB08A100KXZA69S899	iitem_01KR020EX5ZTR4NACK24QNW40Z	pvitem_01KR020EYQRJ15AGR6KVJ4T15T	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETCM2P3SHKM6QCX7F0R	iitem_01KR020EX5VQY74D48QCAWMN21	pvitem_01KR020EYRZ7JZDZC8P20J860F	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETCD2V6TWDTH237WWXS	iitem_01KR020EX5SV8MY6AP6SVJRCD8	pvitem_01KR020EYRSR74MQRZ08FDBTBY	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETC9YTNQ2R389GGK632	iitem_01KR020EX69GYYKR3Z3D7XRPEE	pvitem_01KR020EYR725YW8DRSYMV10DX	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETCMNY3XK6FWPZMV80P	iitem_01KR020EX6J44SDNPBDJSXP0T9	pvitem_01KR020EYRCFT3D76MX6C730D1	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETCF0XK6CXHDZF4VDG6	iitem_01KR020EX6T7K2VE5P73QR7NQH	pvitem_01KR020EYR3HQ9W8Z0CCFMCX7A	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETCSZY4HANHH4A1W8EH	iitem_01KR020EX6ZPY24SYD191VXMKW	pvitem_01KR020EYRXE3H5295Q6W7SJD8	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:50.162+00	2026-05-07 02:27:50.162+00
variant_01KR020ETC29TD5VQKK84GBX88	iitem_01KR020EX6QWCFSMEP8YYBSSPB	pvitem_01KR020EYRGTQ4XRYJ6QWJYCSA	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:53.836+00	2026-05-07 02:27:53.836+00
variant_01KR020ETCWNVY9HHJZC3H5ZBW	iitem_01KR020EX69M0Z7688GPDKYHKG	pvitem_01KR020EYRGS3EVSM63JXFEFMQ	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:53.836+00	2026-05-07 02:27:53.836+00
variant_01KR020ETCAAGAQ6H6AY9VKVFW	iitem_01KR020EX6QYWKD99X6AAHKCNP	pvitem_01KR020EYR9Q3NH2SAW1MXFTQF	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:53.836+00	2026-05-07 02:27:53.836+00
variant_01KR020ETC2F8A2W70G2X4838T	iitem_01KR020EX6RD20NC1WN7W3HNSE	pvitem_01KR020EYRN1BPNBWQ0P2AV15N	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:53.836+00	2026-05-07 02:27:53.836+00
variant_01KR020ETCEVTQ2XRXJ7F3E1WG	iitem_01KR020EX6YCRYT4CG1XA68GV5	pvitem_01KR020EYRX8C73J60SF4G27T2	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:53.836+00	2026-05-07 02:27:53.836+00
variant_01KR020ETAZEVC6V5ZAXABY84X	iitem_01KR020EX4WNJ7C2JGR6FZ138A	pvitem_01KR020EYQD7YRCYGN65P6TF22	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.258+00	2026-05-07 02:27:45.256+00
variant_01KR020ETB263T794NKZ5W5HKF	iitem_01KR020EX554WR4DFPH5EZ019C	pvitem_01KR020EYQ2V6J7KXQMCFQYJB8	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.258+00	2026-05-07 02:27:45.256+00
variant_01KR020ETBVWFPKTJQHSJ52Z49	iitem_01KR020EX5NW10C17RCH4SWJ7Q	pvitem_01KR020EYQS0X5SEVBMQ5CWHDF	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:45.258+00	2026-05-07 02:27:45.256+00
variant_01KR020ETDB9M8H0W5SNDNEY3P	iitem_01KR020EX7NKBDA8FYVGC4G1DY	pvitem_01KR020EYSHTJFSJX9B3Z0Y1Y8	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETDCVARXQJDY4CSM9ER	iitem_01KR020EX71VPCA5F2HEHJYTK2	pvitem_01KR020EYSASKRR4S4EPF40YHJ	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETDAMHG09KADDC98CJ4	iitem_01KR020EX7X273NEX19GNVSB5Q	pvitem_01KR020EYSAG6HSHVN6JAKQE4T	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETD9PGVQFM456TF4CMG	iitem_01KR020EX7T2Z3JZNWES7C7Z70	pvitem_01KR020EYSNFZ6SW5A6Z5ZXZXW	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETD6BYYR52KBBCWYCGV	iitem_01KR020EX7M3RZYN9Y7NSS0HG4	pvitem_01KR020EYS4MFS2ZJTRJBRQJST	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEKR37JNRZPRS20EP6	iitem_01KR020EX7R04DZCPDBXAJF2V1	pvitem_01KR020EYSM9Z3ZAGE5JWCY3D2	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETE77BQQ2VG9ESQNYY6	iitem_01KR020EX7RXYVRAD74YYKD39B	pvitem_01KR020EYSFQZBSN464C8VK4WK	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEHXZDC4A1ASE24THB	iitem_01KR020EX78P0M73HXFGAFN5HH	pvitem_01KR020EYS8PDWSDMGV5Y8CHQG	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEAX2850MZV7J07B87	iitem_01KR020EX7DXA31D5X9Z72BHV6	pvitem_01KR020EYSQMXEQEK0MBXW8YWG	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETE51ZYVD78NWEZPACD	iitem_01KR020EX74SEDC8MN69SK8E02	pvitem_01KR020EYSEKTHN1FNHFAA5F6W	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEMDGPHPA7B3MSPK6N	iitem_01KR020EX8V5A2HCE2QX4SNS1V	pvitem_01KR020EYTPWERZ9FTC58K5WW8	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEW9N6AQNQKYPYZVJN	iitem_01KR020EX87H55YN4G86ZZJF2W	pvitem_01KR020EYT42DR00KAAPQA3NDW	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEHY12KS15A0VKWAKW	iitem_01KR020EX847D28S7D8D2B6X5J	pvitem_01KR020EYTRY958SABRXAY8HXP	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETECETWVWK4K8SV81QB	iitem_01KR020EX8B76Q6J5382C5GZJ5	pvitem_01KR020EYTWP7X4H1KNJCDK9RW	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEA590J77TANRTPMK8	iitem_01KR020EX86MVAH148R9DESJNQ	pvitem_01KR020EYTJN92VSZMDCJYT4WW	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETEV73J8Z3ZCGKZNHNQ	iitem_01KR020EX8W1WBDC6AQZFA4PNR	pvitem_01KR020EYTQ906AWHZQDG18J32	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFYVVSCCM53BCKF1BT	iitem_01KR020EX8W0ZA15G6CDB3C9BC	pvitem_01KR020EYTAQSVBGZ63C4AGK58	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFG6SFD5V30GJ9ZRRC	iitem_01KR020EX9GAE3G8GJCSFDHJW5	pvitem_01KR020EYV3NF8YZN68BR70MQ0	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETF19P521JJZHZQESM5	iitem_01KR020EX90437JTA23EE72T41	pvitem_01KR020EYVSQ7VP3MBCKQQKYA8	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETF9P17MDFA45PNBTTG	iitem_01KR020EX9E83M4A0CTRBNT1AM	pvitem_01KR020EYV4ZK747T2WJY4BRE5	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFVX54VD7BD9HH5WZ3	iitem_01KR020EX9JQJ3SZ8XYNHG4VTK	pvitem_01KR020EYV5GZ5BM458W7GPPB9	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFTYMEQ5RQP25CQCS4	iitem_01KR020EX9KGCEHYE9VPHWXP1V	pvitem_01KR020EYVGWDD9GVVDBWS84D0	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFCN0FHCG3298G1EEA	iitem_01KR020EXA2Q9AP4877N7H88KR	pvitem_01KR020EYVD2ZGW73JYZ7JHKD7	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFVW3KEDXV93FXG4VS	iitem_01KR020EXA3QBYB535FA2MZ1P9	pvitem_01KR020EYV97WBE2Q314YK5YQM	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFMPKXV00VEGYYAHBQ	iitem_01KR020EXAYJNHWCBN23RCA8AS	pvitem_01KR020EYVK5A8DYWM8Z9QB9ZS	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFTG8884AXYCRR3CHD	iitem_01KR020EXAFE7MTZW5B11SA7JC	pvitem_01KR020EYVRTF2TNSHNP3F5VR7	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETFQHSZNVECZ3B34M5R	iitem_01KR020EXA4KZC29JV5CW5K96Z	pvitem_01KR020EYV8T14WA2WSVY4TQ6F	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETGEV7CP486YHF2KM9A	iitem_01KR020EXAK1V99BEGEAFZQF4M	pvitem_01KR020EYWK91CFGVG9CSVGXP3	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETGP6D4NF692QN98Q17	iitem_01KR020EXA828TAVSPGDH43S4W	pvitem_01KR020EYWS1DAEH6Z6K84RZMK	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETGPJBYN7XG7AM4N9EQ	iitem_01KR020EXAXZQYQQR45Q3P6ETE	pvitem_01KR020EYWA6AN7FZZXAWNH34M	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETGNEN24BV00RNZMNHB	iitem_01KR020EXAY3CSWNY2TJ6B4DE6	pvitem_01KR020EYWCA85C3SP3FD3WN2V	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETGVPA9384N95T0S3V0	iitem_01KR020EXAR50N3JZ11TD2R90W	pvitem_01KR020EYWZSCXF2C74XK9SYTY	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.278+00	2026-05-07 02:27:48.276+00
variant_01KR020ETG3W7VBM411CNNEM95	iitem_01KR020EXBBEFNVC1AZT2GRK1F	pvitem_01KR020EYWX73BTWKHWEDVHD14	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.279+00	2026-05-07 02:27:48.276+00
variant_01KR020ETGXJ0ET0A98V9H7PGV	iitem_01KR020EXB7EDH0RJMVPG26Q9M	pvitem_01KR020EYW2BYPHGWR4DX2HYRB	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.279+00	2026-05-07 02:27:48.276+00
variant_01KR020ETGY2PKBHRG2SVGA9HJ	iitem_01KR020EXBZ6GFS2GGR3JZWFJG	pvitem_01KR020EYXW2WQ9J5T16W6C599	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.279+00	2026-05-07 02:27:48.276+00
variant_01KR020ETHMB8SQ29ADKGD52V6	iitem_01KR020EXBNJAVMHTGX3J6MD1D	pvitem_01KR020EYXXBJ7N3Q0BJ66XJ9B	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:28:00.105+00	2026-05-07 02:28:00.104+00
variant_01KR020ETHSEYS8PZZEM45KAT6	iitem_01KR020EXBMZ5RS0221NTY4BG9	pvitem_01KR020EYXZPRZQH23HP2XD2NE	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:28:00.105+00	2026-05-07 02:28:00.104+00
variant_01KR020ETHADYH6R4ZRH0RJRJB	iitem_01KR020EXB7XM4X8S8CRSVQHF7	pvitem_01KR020EYXT4TWPSEEN9B8QTKC	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:28:00.105+00	2026-05-07 02:28:00.104+00
variant_01KR020ETH0T07AXYY7TVZZPXB	iitem_01KR020EXBN1WM7CM1YM5F0RQ7	pvitem_01KR020EYXTP90ZCQTVNSW6QES	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:28:00.105+00	2026-05-07 02:28:00.104+00
variant_01KR020ETHACSVTSE4AB5R606E	iitem_01KR020EXC447FS5KPEEKBJ594	pvitem_01KR020EYX8PB5DYNCEP5HQ896	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:28:00.105+00	2026-05-07 02:28:00.104+00
variant_01KR020ETG84KBNSAHXQVCX0FR	iitem_01KR020EXBEE109PHV5AZ14V4B	pvitem_01KR020EYXSGDWCPCJEHAJF3XF	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:28:02.977+00	2026-05-07 02:28:02.977+00
variant_01KR020ETHJ6QF5WWBNT7S8C74	iitem_01KR020EXB2H31P5Q75MT32YQX	pvitem_01KR020EYXTHHT1N56PHDXVM41	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:28:02.977+00	2026-05-07 02:28:02.977+00
variant_01KR020ETGVS0AN1Y68D03XV2J	iitem_01KR020EXBFJEGNZZ55ZMPZA6P	pvitem_01KR020EYX5E392EJQVXGCA0JE	1	2026-05-07 01:49:33.010327+00	2026-05-07 02:27:48.279+00	2026-05-07 02:27:48.276+00
\.


--
-- Data for Name: product_variant_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_option (variant_id, option_value_id) FROM stdin;
variant_01KQPHSETB7R9QF7PDKXBGCAFH	optval_01KQPHSERCNKFKJEZ817E5K44V
variant_01KQPHSETB7R9QF7PDKXBGCAFH	optval_01KQPHSERD8E9A844RECKE9707
variant_01KQPHSETB8ESJBWT0SN7Q06WT	optval_01KQPHSERCNKFKJEZ817E5K44V
variant_01KQPHSETB8ESJBWT0SN7Q06WT	optval_01KQPHSERDBQX9FBEBSXJ9CMRQ
variant_01KQPHSETBT3C6BGKZN2R71CGB	optval_01KQPHSERCA7NY240XRCKMTRSK
variant_01KQPHSETBT3C6BGKZN2R71CGB	optval_01KQPHSERD8E9A844RECKE9707
variant_01KQPHSETB3W7VKWHH89Q1YWFZ	optval_01KQPHSERCA7NY240XRCKMTRSK
variant_01KQPHSETB3W7VKWHH89Q1YWFZ	optval_01KQPHSERDBQX9FBEBSXJ9CMRQ
variant_01KQPHSETBXX0P8VQGGHNRK0KC	optval_01KQPHSERCXDDETR7KEXBQ3FSG
variant_01KQPHSETBXX0P8VQGGHNRK0KC	optval_01KQPHSERD8E9A844RECKE9707
variant_01KQPHSETBRGKPJJFKX8SYK79R	optval_01KQPHSERCXDDETR7KEXBQ3FSG
variant_01KQPHSETBRGKPJJFKX8SYK79R	optval_01KQPHSERDBQX9FBEBSXJ9CMRQ
variant_01KQPHSETBR16VG1NEQ6WGJ3D4	optval_01KQPHSERC847BYCGG0WEN9BEZ
variant_01KQPHSETBR16VG1NEQ6WGJ3D4	optval_01KQPHSERD8E9A844RECKE9707
variant_01KQPHSETB4DNSMFPVNTA2VXNH	optval_01KQPHSERC847BYCGG0WEN9BEZ
variant_01KQPHSETB4DNSMFPVNTA2VXNH	optval_01KQPHSERDBQX9FBEBSXJ9CMRQ
variant_01KQPHSETC3J25MS5R17WG7YJ7	optval_01KQPHSERES56NGG2SVYMVVNEK
variant_01KQPHSETC3FKD990GD5A020AY	optval_01KQPHSERETW9X7ND4YT4RMQ6W
variant_01KQPHSETC1B0H4XYH05YHD1AZ	optval_01KQPHSERE5KW7G6HMSC3VAV4S
variant_01KQPHSETCDCFDE957NY4DM4X4	optval_01KQPHSEREHZEZJGTF7D00SVH2
variant_01KQPHSETCK9GHVWRZWJ4P79A8	optval_01KQPHSERF5H8YZ3YN69RSVV1F
variant_01KQPHSETC26DE8CGZJ86MK5RH	optval_01KQPHSERFT30VPPJBSVC1956W
variant_01KQPHSETC487HRT8YPKYBMTMN	optval_01KQPHSERFKGW6NEWEHP7VCRCB
variant_01KQPHSETC7K2VJ6KVE7WF7BAQ	optval_01KQPHSERFWYPSMK5TPRK9QD2P
variant_01KQPHSETDAS7C3AP1M5JGX2FR	optval_01KQPHSERF3M6CMZQP6SWMP4S8
variant_01KQPHSETDBPSXADAAAKC2NZNT	optval_01KQPHSERFGN0THPCK0HZ0AN5Y
variant_01KQPHSETDPER2A94MF1BHQSDY	optval_01KQPHSERFRGF2QK9YVB1V5DMY
variant_01KQPHSETDZY4N3Q476PANCSTE	optval_01KQPHSERF8RJDY1H6HAVWSDHW
variant_01KQPJ7G3BQ37TBEF2A3GT3WZW	optval_01KQPJ7G1EHE8VQ4J4FJBDEDD2
variant_01KQPJ7G3BEX6624X89GF6HQDF	optval_01KQPJ7G1G4FX9AZ45XAHMJSZD
variant_01KQPJ7G3B6ABC5E7ZGZPBQRNY	optval_01KQPJ7G1G8Z8EFRQKZH1NYXJQ
variant_01KR020ET9DSHWMWF9MHJZEGE0	optval_01KR020EPS7XC82TNN1HWCHJWK
variant_01KR020ETAE2NK0JNBE83BVJBJ	optval_01KR020EPSVJMJ15M1GP8GDB86
variant_01KR020ETATPQ5VS6SJHQ4NF7N	optval_01KR020EPTW0YANZR4ZX145MFR
variant_01KR020ETAG2WYH6202KC57DC0	optval_01KR020EPTKJGG3WXKW7YNYXX4
variant_01KR020ETA3V5ARXKJJEV7NR5G	optval_01KR020EPTHCYM6ZA3S1708KNN
variant_01KR020ETAZZFE5SSQTN411K4M	optval_01KR020EPTYQ7N05MAQ6WNQA9T
variant_01KR020ETAD2QW5AVFZK64AEFV	optval_01KR020EPVEQ7W2Z0BCXWCTFBX
variant_01KR020ETAZEVC6V5ZAXABY84X	optval_01KR020EPVR1WEXPTPMK29JY30
variant_01KR020ETB263T794NKZ5W5HKF	optval_01KR020EPWGKHJ9BDV4XAZNKFS
variant_01KR020ETBVWFPKTJQHSJ52Z49	optval_01KR020EPWP6D8BSP4GYQFFWB6
variant_01KR020ETBA1J0CH1QH8SQTKCE	optval_01KR020EQ440AF1RG2XJYPDQ4Z
variant_01KR020ETBN54J2Z2GGN67FYCA	optval_01KR020EQ4QPH5EMFNHWC1CR72
variant_01KR020ETBRG52DRX8FVHXTYTT	optval_01KR020EQ4FEMDZKEAHA4PBM7H
variant_01KR020ETB08A100KXZA69S899	optval_01KR020EQ550GXHWCE7PEQENH9
variant_01KR020ETCM2P3SHKM6QCX7F0R	optval_01KR020EQ5KJPR83CDZMJAM3CV
variant_01KR020ETCD2V6TWDTH237WWXS	optval_01KR020EQ5F6FS2WM461W38KAZ
variant_01KR020ETC9YTNQ2R389GGK632	optval_01KR020EQ5V8P0NSYE52CQ85JQ
variant_01KR020ETCMNY3XK6FWPZMV80P	optval_01KR020EQ5P50F4R8SF8WDJ1QS
variant_01KR020ETCF0XK6CXHDZF4VDG6	optval_01KR020EQ5V8NZX3790A145Q37
variant_01KR020ETCSZY4HANHH4A1W8EH	optval_01KR020EQ6PWGNZYTS84VNV539
variant_01KR020ETC29TD5VQKK84GBX88	optval_01KR020EQ760R0Y87KDK6VC9TV
variant_01KR020ETCWNVY9HHJZC3H5ZBW	optval_01KR020EQ8DC41B2EVV872AWW7
variant_01KR020ETCAAGAQ6H6AY9VKVFW	optval_01KR020EQ8F2DW2JZETESVX5G0
variant_01KR020ETC2F8A2W70G2X4838T	optval_01KR020EQ8DNFG4ZN7HSQ3RW00
variant_01KR020ETCEVTQ2XRXJ7F3E1WG	optval_01KR020EQ8Z30RCXH3QTT671QF
variant_01KR020ETDD8V2N3WJXYWGK96S	optval_01KR020EQ9JQVR15N116W3S7PN
variant_01KR020ETDGSYR7NP8XFN86HAW	optval_01KR020EQ99NXD0V4GZ2H264K0
variant_01KR020ETDNSSHCTW6T1A07TFD	optval_01KR020EQ9CAEXXSX6454C73M6
variant_01KR020ETDB9M8H0W5SNDNEY3P	optval_01KR020EQ9977R49RT6ZZ2MTDJ
variant_01KR020ETDCVARXQJDY4CSM9ER	optval_01KR020EQ9XV71DQGQ9GNCV9RN
variant_01KR020ETDAMHG09KADDC98CJ4	optval_01KR020EQ9MJT24H9BSJHT19B3
variant_01KR020ETD9PGVQFM456TF4CMG	optval_01KR020EQ9A9KT28XVXBYR3FZN
variant_01KR020ETD6BYYR52KBBCWYCGV	optval_01KR020EQA78DXGP8PK35SHNMP
variant_01KR020ETEKR37JNRZPRS20EP6	optval_01KR020EQAC2Q65D0RE1YV1G8B
variant_01KR020ETE77BQQ2VG9ESQNYY6	optval_01KR020EQA6SD7G5F8VBD7H8RN
variant_01KR020ETEHXZDC4A1ASE24THB	optval_01KR020EQAMZKWZWGMSCHNZHA7
variant_01KR020ETEAX2850MZV7J07B87	optval_01KR020EQAYYK7YT2JA6Y75B05
variant_01KR020ETE51ZYVD78NWEZPACD	optval_01KR020EQA07QYVS9V10F3YT13
variant_01KR020ETEMDGPHPA7B3MSPK6N	optval_01KR020EQAKEYWKHYZ1P5Y1G66
variant_01KR020ETEW9N6AQNQKYPYZVJN	optval_01KR020EQA7H2GQ0YCNYYPA4XZ
variant_01KR020ETEHY12KS15A0VKWAKW	optval_01KR020EQAJV36XT5MS0EW4W0W
variant_01KR020ETECETWVWK4K8SV81QB	optval_01KR020EQA8AFG8XEQEEP2TYA1
variant_01KR020ETEA590J77TANRTPMK8	optval_01KR020EQA0VWAW81CY5NPPSN1
variant_01KR020ETEV73J8Z3ZCGKZNHNQ	optval_01KR020EQA9NN4S37NY911Y40T
variant_01KR020ETFYVVSCCM53BCKF1BT	optval_01KR020EQAAMXBWFC7T91W5K0X
variant_01KR020ETFG6SFD5V30GJ9ZRRC	optval_01KR020EQA2M0EBDX7K9X7NKMK
variant_01KR020ETF19P521JJZHZQESM5	optval_01KR020EQAHH65GBMQBBP7JQ1D
variant_01KR020ETF9P17MDFA45PNBTTG	optval_01KR020EQAN6Q135K6WE5T7YPS
variant_01KR020ETFVX54VD7BD9HH5WZ3	optval_01KR020EQAXHJKQ2ZGAE7A8YNX
variant_01KR020ETFTYMEQ5RQP25CQCS4	optval_01KR020EQB25K1VESW15YVEYAM
variant_01KR020ETFCN0FHCG3298G1EEA	optval_01KR020EQBHMRD4KX6EJ5PNPWG
variant_01KR020ETFVW3KEDXV93FXG4VS	optval_01KR020EQB9SW26BNHP9ZFT4KE
variant_01KR020ETFMPKXV00VEGYYAHBQ	optval_01KR020EQBM0H0KGQ41XB6DQVY
variant_01KR020ETFTG8884AXYCRR3CHD	optval_01KR020EQBVSPS7F40ZR065FVR
variant_01KR020ETFQHSZNVECZ3B34M5R	optval_01KR020EQB32FCWAQG3RZ4Z39C
variant_01KR020ETGEV7CP486YHF2KM9A	optval_01KR020EQBKSZNN7DXVFH85G8B
variant_01KR020ETGP6D4NF692QN98Q17	optval_01KR020EQBQ40A4WYN8121YN8M
variant_01KR020ETGPJBYN7XG7AM4N9EQ	optval_01KR020EQBMJMNZQTEDP2HAJD3
variant_01KR020ETGNEN24BV00RNZMNHB	optval_01KR020EQBSDAHSV8TFJX4JP0S
variant_01KR020ETGVPA9384N95T0S3V0	optval_01KR020EQBSKBXFXYY5GNQRJ49
variant_01KR020ETG3W7VBM411CNNEM95	optval_01KR020EQBAN6X1JT4WQHRDP4R
variant_01KR020ETGXJ0ET0A98V9H7PGV	optval_01KR020EQB6WKFDZ6MEM7KKY5S
variant_01KR020ETGY2PKBHRG2SVGA9HJ	optval_01KR020EQBK08EAP0KMQR6BYMH
variant_01KR020ETGVS0AN1Y68D03XV2J	optval_01KR020EQBXMAE53GHBD7TG3XH
variant_01KR020ETG84KBNSAHXQVCX0FR	optval_01KR020EQC8D8FXH3AYKV1YPGY
variant_01KR020ETHJ6QF5WWBNT7S8C74	optval_01KR020EQCVWB56EKQ4TCX1K7G
variant_01KR020ETHMB8SQ29ADKGD52V6	optval_01KR020EQDP4T5S78A4CP7E9BR
variant_01KR020ETHSEYS8PZZEM45KAT6	optval_01KR020EQD3VW6ZGPC4MFMQ3QZ
variant_01KR020ETHADYH6R4ZRH0RJRJB	optval_01KR020EQDA355H3D11WB434WQ
variant_01KR020ETH0T07AXYY7TVZZPXB	optval_01KR020EQDV6HFCKNJS339RHND
variant_01KR020ETHACSVTSE4AB5R606E	optval_01KR020EQDJ8VX3MGNA04AQRS3
variant_01KR06N20GQ28JY1DK4ZFQ6G8B	optval_01KR06N1Y4YDKGP2BHRFKQ2GC1
variant_01KR06N20GZ7RYQYEJFGDPYP3W	optval_01KR06N1Y4W2VFDF20WZADPGB4
variant_01KR06N20G0FF5TVPPX3P9SMQ0	optval_01KR06N1Y4QDWJQW1XBEM87V86
variant_01KR06N20GCBC4DDWRZHY3KA3G	optval_01KR06N1Y4SV920WJE5556FKHT
variant_01KR21MGGZXFD0G0MTF1TM9MCC	optval_01KR21MGDWW9K1QSQ9HA5E0HA1
variant_01KR250JCN0DS48VEGZKF0S8KS	optval_01KR24XQW1BT5G8FBBXWXN554Z
variant_01KR251F0B3N25NR865YFMNSG6	optval_01KR24XQW2F2TR6V4ZB2KB475Y
variant_01KR252HHWRY9NQKMDGDNBXY75	optval_01KR24XQW29T2MKFFBMEHQF47D
variant_01KR2535GWTAV92J6P4DTNK1SF	optval_01KR24XQW2M4DQ3K1PWJMN5BQ6
variant_01KR26GH9FHCS47X4NKJ2100PV	optval_01KR26GH2PR8ERW3YRAG5DV9BV
variant_01KR26GH9F4XTCVJ4RM405AZ6W	optval_01KR26GH2XCK11YR99V3Q6JM0B
variant_01KR26GH9GB74FMJSRCME1J1Z7	optval_01KR26GH2X6YQ0D0M2SEV2KX3A
variant_01KR26GH9G01H235TN94XZ14T7	optval_01KR26GH2XFYV0BN5JZ5E3P8FZ
variant_01KR2AAAZKNZPEQ4693H2RM8Z5	optval_01KR2AAAVZWDXPE49Z4SQYCE0J
variant_01KR2AAAZKNST690FATR7E6A2R	optval_01KR2AAAVZZ181RR2VDXMRN4Y9
variant_01KR2AAAZM5K2Y3TBDHBR6QDDF	optval_01KR2AAAW0W42TR8YXZZPTH03T
variant_01KR2AAAZM3V4X6SRT2RNP7K35	optval_01KR2AAAW0WMQPR8AHEAWQ8NZX
variant_01KR2CNPQ1PSQ1DECMG56FMG2Q	optval_01KR2CNPMAA76WCEV79R4RXS62
\.


--
-- Data for Name: product_variant_price_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_price_set (variant_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
variant_01KQPJ7G3BEX6624X89GF6HQDF	pset_01KQPJ7G4JFR9DVF871PRD3E1T	pvps_01KQPJ7G5BF4QK4H64A0N6M712	2026-05-03 09:20:36.520822+00	2026-05-07 02:52:47.915+00	2026-05-07 02:52:47.915+00
variant_01KQPJ7G3BQ37TBEF2A3GT3WZW	pset_01KQPJ7G4JP5MMS1AVFW2P5GZD	pvps_01KQPJ7G5BBANS64WXFZGCGBJ7	2026-05-03 09:20:36.520822+00	2026-05-07 02:53:04.686+00	2026-05-07 02:53:04.686+00
variant_01KR06N20GQ28JY1DK4ZFQ6G8B	pset_01KR06N21E8XB36KTT9Z8SVWYV	pvps_01KR06N22NQK1HZ9GH8R505T1X	2026-05-07 03:10:42.260079+00	2026-05-07 03:10:42.260079+00	\N
variant_01KR06N20GZ7RYQYEJFGDPYP3W	pset_01KR06N21EK2PSYNYB9DP16HRA	pvps_01KR06N22NZMFJQ167S8GGZMQV	2026-05-07 03:10:42.260079+00	2026-05-07 03:10:42.260079+00	\N
variant_01KR06N20G0FF5TVPPX3P9SMQ0	pset_01KR06N21EW60TJ0EJRF5KMX10	pvps_01KR06N22N4F32X87W5VW7H3MG	2026-05-07 03:10:42.260079+00	2026-05-07 03:10:42.260079+00	\N
variant_01KR06N20GCBC4DDWRZHY3KA3G	pset_01KR06N21EA9GA9VZGVWBVE0P0	pvps_01KR06N22NP329C9Y00CKNZ20X	2026-05-07 03:10:42.260079+00	2026-05-07 03:10:42.260079+00	\N
variant_01KR251F0B3N25NR865YFMNSG6	pset_01KR251F10MRSSP2A5NGDX60JD	pvps_01KR251F1H78SJ26GRFGTDPQK7	2026-05-07 21:21:00.46443+00	2026-05-07 21:21:00.46443+00	\N
variant_01KR26GH9FHCS47X4NKJ2100PV	pset_01KR26GHCMYDAHFKXA3GNDA67K	pvps_01KR26GHENX142QRE6HJ1K20CN	2026-05-07 21:46:43.028465+00	2026-05-07 21:46:43.028465+00	\N
variant_01KR26GH9F4XTCVJ4RM405AZ6W	pset_01KR26GHCNRKZT40BZF2JDQKDR	pvps_01KR26GHENT8GB24YN8FJR79JS	2026-05-07 21:46:43.028465+00	2026-05-07 21:46:43.028465+00	\N
variant_01KR26GH9GB74FMJSRCME1J1Z7	pset_01KR26GHCPFVX660RM1SWW57AQ	pvps_01KR26GHEN3WYVAWE1Q8SW9TNY	2026-05-07 21:46:43.028465+00	2026-05-07 21:46:43.028465+00	\N
variant_01KR26GH9G01H235TN94XZ14T7	pset_01KR26GHCQ1Z04N3KF057Z8J1Q	pvps_01KR26GHEP50B5BG609BA6NW0D	2026-05-07 21:46:43.028465+00	2026-05-07 21:46:43.028465+00	\N
variant_01KQPHSETC3J25MS5R17WG7YJ7	pset_01KQPHSEW95V710Q9JD43H56MC	pvps_01KQPHSEXGGSCZ9EY4RA143Q7J	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:54.611+00	2026-05-03 18:16:54.61+00
variant_01KQPHSETC3FKD990GD5A020AY	pset_01KQPHSEW93NHF7CTSE01687DX	pvps_01KQPHSEXGHMVZZMTKYN21CBCD	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:54.611+00	2026-05-03 18:16:54.61+00
variant_01KQPHSETC1B0H4XYH05YHD1AZ	pset_01KQPHSEW928VS0864BHB91VNC	pvps_01KQPHSEXGVSQNCNXDG9SRDH6C	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:54.611+00	2026-05-03 18:16:54.61+00
variant_01KQPHSETCDCFDE957NY4DM4X4	pset_01KQPHSEW9J4ZT87H195FKSJWS	pvps_01KQPHSEXGR7AAGFDVFS1G58AZ	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:54.611+00	2026-05-03 18:16:54.61+00
variant_01KQPHSETB7R9QF7PDKXBGCAFH	pset_01KQPHSEW75VT588CR0SGZZ27P	pvps_01KQPHSEXF98PGFQWYFXA35NQP	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETB8ESJBWT0SN7Q06WT	pset_01KQPHSEW7DBKKBV76YYJ02DMT	pvps_01KQPHSEXFW4XNGSSCRPR6BZS7	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETBT3C6BGKZN2R71CGB	pset_01KQPHSEW7WCS4HNXYC9KTT2PF	pvps_01KQPHSEXGF4KTQRG2SZJGNB98	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETB3W7VKWHH89Q1YWFZ	pset_01KQPHSEW8GZQBW4C188XJ902T	pvps_01KQPHSEXG3JXB0VKV05BH5MVY	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETBXX0P8VQGGHNRK0KC	pset_01KQPHSEW85GKD6WGDHBAMD0EN	pvps_01KQPHSEXGGH49104S2ZMB9DHT	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETBRGKPJJFKX8SYK79R	pset_01KQPHSEW8JNMTXJRXCQYDRZMB	pvps_01KQPHSEXGNXXWCZ3PM2DAAEPE	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETBR16VG1NEQ6WGJ3D4	pset_01KQPHSEW8BPD1GAQC1QGZYVEX	pvps_01KQPHSEXGFXJW97VZFJNRXTGZ	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETB4DNSMFPVNTA2VXNH	pset_01KQPHSEW84NXZG0ABCN356EBT	pvps_01KQPHSEXGSYGSWH8S7HRJW7CD	2026-05-03 09:12:56.494582+00	2026-05-03 18:16:58.645+00	2026-05-03 18:16:58.645+00
variant_01KQPHSETCK9GHVWRZWJ4P79A8	pset_01KQPHSEW9HDK74QFRQSJPN4TW	pvps_01KQPHSEXGF35GJTVP77MEZ4FC	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:02.289+00	2026-05-03 18:17:02.289+00
variant_01KQPHSETC26DE8CGZJ86MK5RH	pset_01KQPHSEWAYVESARFBEC2BTV2G	pvps_01KQPHSEXGRJJANA69YB41ZP95	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:02.289+00	2026-05-03 18:17:02.289+00
variant_01KQPHSETC487HRT8YPKYBMTMN	pset_01KQPHSEWA89AASFWWTHZ8E642	pvps_01KQPHSEXG0J5W64588KWKTG1G	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:02.289+00	2026-05-03 18:17:02.289+00
variant_01KQPHSETC7K2VJ6KVE7WF7BAQ	pset_01KQPHSEWASR9022TASSGTJAEC	pvps_01KQPHSEXHXXZSWYQ9N9V59GDN	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:02.289+00	2026-05-03 18:17:02.289+00
variant_01KQPHSETDAS7C3AP1M5JGX2FR	pset_01KQPHSEWAF8P7TC2EZPNZTQ1Z	pvps_01KQPHSEXHG2G8JMVJNTQHC4ZQ	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:06.187+00	2026-05-03 18:17:06.187+00
variant_01KQPHSETDBPSXADAAAKC2NZNT	pset_01KQPHSEWAQRX9SPBGQANKP81Q	pvps_01KQPHSEXH0GX0B330GGEB99YQ	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:06.187+00	2026-05-03 18:17:06.187+00
variant_01KQPHSETDPER2A94MF1BHQSDY	pset_01KQPHSEWAS12A2QX7ABPG5FSB	pvps_01KQPHSEXHHGCXM5WAVJ4HYEF0	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:06.187+00	2026-05-03 18:17:06.187+00
variant_01KQPHSETDZY4N3Q476PANCSTE	pset_01KQPHSEWBZZ0M85KS23P8SG30	pvps_01KQPHSEXHCD2N4FK01JZ3BHRB	2026-05-03 09:12:56.494582+00	2026-05-03 18:17:06.187+00	2026-05-03 18:17:06.187+00
variant_01KQPJ7G3B6ABC5E7ZGZPBQRNY	pset_01KQPJ7G4JKDRV6CYGNHHGTSD5	pvps_01KQPJ7G5B8NN8XKK1694CHTNT	2026-05-03 09:20:36.520822+00	2026-05-03 18:17:14.66+00	2026-05-03 18:17:14.66+00
variant_01KR020ET9DSHWMWF9MHJZEGE0	pset_01KR020EZWG3DFD68NPXQ621M2	pvps_01KR020F2XPYHJ1BT0NMG70DR2	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETAE2NK0JNBE83BVJBJ	pset_01KR020EZW1WW3C5K69MDQ4AG7	pvps_01KR020F2XKBRKAETJSH6Y9MRX	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETATPQ5VS6SJHQ4NF7N	pset_01KR020EZWTCPRAWQ9A21D7B3S	pvps_01KR020F2X1B93YP728QEHXT4B	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETAG2WYH6202KC57DC0	pset_01KR020EZWZBH73B4SB9WKV55S	pvps_01KR020F2YJN2J3A8MC3EMHT20	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETA3V5ARXKJJEV7NR5G	pset_01KR020EZW7ARZ9SHZNGW7EQ51	pvps_01KR020F2YNFYA4CXESXDDC24F	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETAZZFE5SSQTN411K4M	pset_01KR020EZXXHXH35FXKP1866EG	pvps_01KR020F2Y62JZFZFX6FG7X7DS	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETAD2QW5AVFZK64AEFV	pset_01KR020EZXS07B3MBVQMHNP34C	pvps_01KR020F2YR5N2D4A1BK1CVDC4	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETAZEVC6V5ZAXABY84X	pset_01KR020EZX682M721TD0S34SJQ	pvps_01KR020F2YBCGGZ7GFBF5SAA6W	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETB263T794NKZ5W5HKF	pset_01KR020EZX4YZ78DFZM0MVSEX9	pvps_01KR020F2Y7PZ979HKK9M1STZ2	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR020ETBVWFPKTJQHSJ52Z49	pset_01KR020EZYAPSNC4ADMXKM4FKK	pvps_01KR020F2Z6SA2NDHEE4K1HZVW	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:45.303+00	2026-05-07 02:27:45.3+00
variant_01KR21MGGZXFD0G0MTF1TM9MCC	pset_01KR21MGJ2K3CXCZKTY7HSPH19	pvps_01KR21MGKDGWQ19ZZ70R56BXD2	2026-05-07 20:21:30.347729+00	2026-05-07 21:19:12.976+00	2026-05-07 21:19:12.976+00
variant_01KR252HHWRY9NQKMDGDNBXY75	pset_01KR252HJQNQGHEPJ46N6GYZAT	pvps_01KR252HMX9K9MJTM4EW7FHH6Z	2026-05-07 21:21:35.891435+00	2026-05-07 21:21:35.891435+00	\N
variant_01KR2AAAZKNZPEQ4693H2RM8Z5	pset_01KR2AAB0SAFNDT6FQ5C82SCJ1	pvps_01KR2AAB26Z6KYVAFWX46XDC9V	2026-05-07 22:53:14.182625+00	2026-05-07 22:53:14.182625+00	\N
variant_01KR2AAAZKNST690FATR7E6A2R	pset_01KR2AAB0T5W87FQQ3MP4DSFGM	pvps_01KR2AAB27JY545D5EPD1TEJ6E	2026-05-07 22:53:14.182625+00	2026-05-07 22:53:14.182625+00	\N
variant_01KR2AAAZM5K2Y3TBDHBR6QDDF	pset_01KR2AAB0VA5MWDS8T7E0C48YM	pvps_01KR2AAB27FWXHBVRPM2SQV6KR	2026-05-07 22:53:14.182625+00	2026-05-07 22:53:14.182625+00	\N
variant_01KR2AAAZM3V4X6SRT2RNP7K35	pset_01KR2AAB0WTZPHGV80BE5A1N3W	pvps_01KR2AAB27KHKC36DXK2N0V1DB	2026-05-07 22:53:14.182625+00	2026-05-07 22:53:14.182625+00	\N
variant_01KR020ETBA1J0CH1QH8SQTKCE	pset_01KR020EZYV4SDYP00WWQAFV61	pvps_01KR020F2ZSQ29RFM9RKF21BVY	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETBN54J2Z2GGN67FYCA	pset_01KR020EZYW4MP27R6H16RPVJS	pvps_01KR020F2Z7NRX6SPV0AZ23YX3	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETBRG52DRX8FVHXTYTT	pset_01KR020EZYEGG7NASAVSMATX0S	pvps_01KR020F2ZYX58D23P8001DTXC	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETB08A100KXZA69S899	pset_01KR020EZY0FJ43ZZ8Y2344N7Y	pvps_01KR020F2Z320B5XFT501W9S1T	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETCM2P3SHKM6QCX7F0R	pset_01KR020EZYAG6828PN9VJBDD9D	pvps_01KR020F30QYB1YW06XG7SZA0N	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETCD2V6TWDTH237WWXS	pset_01KR020EZY33QJXHSY1K2HC01H	pvps_01KR020F30E0G1Z8D5BVCSQB2K	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETC9YTNQ2R389GGK632	pset_01KR020EZZ1YEMH7WA26FSPHX3	pvps_01KR020F30HYFPF68XFM07B251	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETCMNY3XK6FWPZMV80P	pset_01KR020EZZDR8B2E7VVYTJBKFM	pvps_01KR020F30W6RVT6XW361R37A5	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETCF0XK6CXHDZF4VDG6	pset_01KR020EZZ9QG5WT1Q9KHY0AN6	pvps_01KR020F30AAG9MN3Q8MDGBC7S	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETCSZY4HANHH4A1W8EH	pset_01KR020EZZREZTFTA0PFG2PY6R	pvps_01KR020F30K94MHTXRHBE218T8	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:50.171+00	2026-05-07 02:27:50.171+00
variant_01KR020ETC29TD5VQKK84GBX88	pset_01KR020EZZFG3YTHXT7EE1YV1T	pvps_01KR020F31E7WY2PH95EX00FWC	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:53.848+00	2026-05-07 02:27:53.848+00
variant_01KR020ETCWNVY9HHJZC3H5ZBW	pset_01KR020EZZT8TPJ1YT38HKG6AJ	pvps_01KR020F31831KKQH4ST10H3SF	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:53.848+00	2026-05-07 02:27:53.848+00
variant_01KR020ETCAAGAQ6H6AY9VKVFW	pset_01KR020EZZ20QS9R6KNT5XWDD2	pvps_01KR020F31RJHKX1J5DGJK1SYW	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:53.848+00	2026-05-07 02:27:53.848+00
variant_01KR020ETC2F8A2W70G2X4838T	pset_01KR020F002PQRN05215BN8HZD	pvps_01KR020F3147NDK001RA86J5KF	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:53.848+00	2026-05-07 02:27:53.848+00
variant_01KR020ETCEVTQ2XRXJ7F3E1WG	pset_01KR020F00JHGJEGEAHB2WYNKW	pvps_01KR020F31PNV55B783M31A85A	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:53.848+00	2026-05-07 02:27:53.848+00
variant_01KR020ETG84KBNSAHXQVCX0FR	pset_01KR020F06AJKGSTDHGKDXNM8W	pvps_01KR020F37DB9XZ35TRD0THWV6	2026-05-07 01:49:33.145799+00	2026-05-07 02:28:02.989+00	2026-05-07 02:28:02.989+00
variant_01KR250JCN0DS48VEGZKF0S8KS	pset_01KR250JDNAN15YRV4M79G1KDV	pvps_01KR250JES2GJDEW6Y6NFG0Z75	2026-05-07 21:20:31.191386+00	2026-05-07 21:20:31.191386+00	\N
variant_01KR2535GWTAV92J6P4DTNK1SF	pset_01KR2535HX9D5M70ST8Y1Q109P	pvps_01KR2535JH6PWXYRNHNTHM7Y9Y	2026-05-07 21:21:56.303404+00	2026-05-07 21:21:56.303404+00	\N
variant_01KR2CNPQ1PSQ1DECMG56FMG2Q	pset_01KR2CNPR2P1MQ4SY7DZQ558P0	pvps_01KR2CNPS28Y9EK9B1EF9V6WC8	2026-05-07 23:34:23.77629+00	2026-05-07 23:34:23.77629+00	\N
variant_01KR020ETDD8V2N3WJXYWGK96S	pset_01KR020F00XNNBC8J8XDF34AK9	pvps_01KR020F31FCFSDNMGKFWMGE2Z	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.306+00	2026-05-07 02:27:48.306+00
variant_01KR020ETDGSYR7NP8XFN86HAW	pset_01KR020F00J4HFHN1T9R2QXQYP	pvps_01KR020F32E6WQM74A6369JKA3	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETDNSSHCTW6T1A07TFD	pset_01KR020F007EQSH7F8CB9R93GJ	pvps_01KR020F32V0XQ194QSX29GNMY	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETDB9M8H0W5SNDNEY3P	pset_01KR020F000KBVN1DZMR5VNSV3	pvps_01KR020F32YPB6NDRHRDVGNWXS	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETDCVARXQJDY4CSM9ER	pset_01KR020F00A8SZTX09E2CXGH8E	pvps_01KR020F32TV01VKNY9KBZND9F	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETDAMHG09KADDC98CJ4	pset_01KR020F01H1SW1Q8J72S8ME98	pvps_01KR020F32Y7SV0H9H8JK6PYKJ	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETD9PGVQFM456TF4CMG	pset_01KR020F018ASFQF27JQNDGY47	pvps_01KR020F32Z37GJP2D4HQVCQ0C	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETD6BYYR52KBBCWYCGV	pset_01KR020F011Z3NMMQR92XHFE2J	pvps_01KR020F32JMM20HJ5RFDT3Z03	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEKR37JNRZPRS20EP6	pset_01KR020F01F1E4K7EK555GPC5G	pvps_01KR020F32RWHKC0XKB9TK08E9	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETE77BQQ2VG9ESQNYY6	pset_01KR020F0181KDED3CCYJ0ESZD	pvps_01KR020F32BWBH1P6FXMT566WM	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEHXZDC4A1ASE24THB	pset_01KR020F02DP6PSQMX1DP67PQ6	pvps_01KR020F33RZMF1XSSNPRF5140	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEAX2850MZV7J07B87	pset_01KR020F02XBNVPMMGT051QVHA	pvps_01KR020F33GD0MZN5WR0AH7PG4	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETE51ZYVD78NWEZPACD	pset_01KR020F02NHW8BPX263FY7XPA	pvps_01KR020F33CK0T3HECARH4KMQY	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEMDGPHPA7B3MSPK6N	pset_01KR020F022B40NMM9FQM59552	pvps_01KR020F33286FY72EGVS4GZHW	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEW9N6AQNQKYPYZVJN	pset_01KR020F02C2SDV590YHE74S1C	pvps_01KR020F333D1NMF8K72RSHZWA	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEHY12KS15A0VKWAKW	pset_01KR020F02AY7MXZ9VT5DNGRYS	pvps_01KR020F332W7MWKE5VRMQ03ZA	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETECETWVWK4K8SV81QB	pset_01KR020F03VC8B4RTFG6AMANWV	pvps_01KR020F33NGB4DE5Z1PCXHHJQ	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEA590J77TANRTPMK8	pset_01KR020F03TP2H3FNR85QEQ3VZ	pvps_01KR020F343W33MRQF4AF56XTZ	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETEV73J8Z3ZCGKZNHNQ	pset_01KR020F0301MYRV87A2SCH2PB	pvps_01KR020F34H3VK989408VTDTJT	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFYVVSCCM53BCKF1BT	pset_01KR020F033EF5DRTZWM3N2G5V	pvps_01KR020F344TYCYB7QDPGS7N82	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFG6SFD5V30GJ9ZRRC	pset_01KR020F038DTDA1HXVWBC0YA0	pvps_01KR020F34Z1588787EWZR346Y	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETF19P521JJZHZQESM5	pset_01KR020F0311NPJW5ANR881CCV	pvps_01KR020F34Z8ZPN0PW6834J9YC	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETF9P17MDFA45PNBTTG	pset_01KR020F031HE59WPCPQXRKN8B	pvps_01KR020F352JYMN8H7NG7FPJ2T	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFVX54VD7BD9HH5WZ3	pset_01KR020F0433KZCNPJEH8TQ3FH	pvps_01KR020F35AHJWS5X2699H13AK	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFTYMEQ5RQP25CQCS4	pset_01KR020F04R1SYHXPWNE2AQ430	pvps_01KR020F35F2YR9MXT6H136ENX	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFCN0FHCG3298G1EEA	pset_01KR020F04GHET4VF74YJTJFD9	pvps_01KR020F35T0PFZ2GP5RR0RP0T	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFVW3KEDXV93FXG4VS	pset_01KR020F043VKB54TBSV6SM7Z8	pvps_01KR020F35Q7FEA19V1CQVV5BM	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFMPKXV00VEGYYAHBQ	pset_01KR020F04GHB8E9HGGB5ERXEZ	pvps_01KR020F36GEDBMM0TWTZFZ763	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFTG8884AXYCRR3CHD	pset_01KR020F042E7YBAXJZJYA2QYJ	pvps_01KR020F36YSAET9MQATQ9TMRA	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETFQHSZNVECZ3B34M5R	pset_01KR020F044QSXS9T710KVF231	pvps_01KR020F36DJ2YZXDJ2ZMPDE09	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGEV7CP486YHF2KM9A	pset_01KR020F04ZJTJ4CM43K6KDKMV	pvps_01KR020F36SENAK1ZKX21DJ5GJ	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGP6D4NF692QN98Q17	pset_01KR020F05AHRPV04KJNK49VJW	pvps_01KR020F36GCG8EA1JCS7TJVCH	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGPJBYN7XG7AM4N9EQ	pset_01KR020F05A3CFH84658JQFVYE	pvps_01KR020F36NR7PR23GEVFNGG7H	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGNEN24BV00RNZMNHB	pset_01KR020F05XE0BFR53R12NGJHH	pvps_01KR020F36VQMZNS5X3G2MPNMA	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGVPA9384N95T0S3V0	pset_01KR020F05MJREMKF91VTNCEZG	pvps_01KR020F364BC6598WZQF28RYZ	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETG3W7VBM411CNNEM95	pset_01KR020F05TM84SJGZ6G46005R	pvps_01KR020F37YAZETTRTCJ1C3SDV	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGXJ0ET0A98V9H7PGV	pset_01KR020F05R6T08B4439P807JB	pvps_01KR020F37BZMXJ5GXW9F9AVEH	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGY2PKBHRG2SVGA9HJ	pset_01KR020F058YFPM95647EZ8N0S	pvps_01KR020F37FBF2FBWA892QEJGW	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETGVS0AN1Y68D03XV2J	pset_01KR020F06AN1N6DNPH94M7ZCN	pvps_01KR020F37YFY9DVMDZBNPTKYD	2026-05-07 01:49:33.145799+00	2026-05-07 02:27:48.307+00	2026-05-07 02:27:48.306+00
variant_01KR020ETHMB8SQ29ADKGD52V6	pset_01KR020F06Q8HBRE5XZ9ZF84X1	pvps_01KR020F37740C1KZY4S1BA2H1	2026-05-07 01:49:33.145799+00	2026-05-07 02:28:00.113+00	2026-05-07 02:28:00.113+00
variant_01KR020ETHSEYS8PZZEM45KAT6	pset_01KR020F06M3PQ3MH72CEQWJAK	pvps_01KR020F3717C7BFQFDDY0QNKY	2026-05-07 01:49:33.145799+00	2026-05-07 02:28:00.113+00	2026-05-07 02:28:00.113+00
variant_01KR020ETHADYH6R4ZRH0RJRJB	pset_01KR020F064R81GTA0CHD0SBRC	pvps_01KR020F37CRG28DQ10NHQVEFS	2026-05-07 01:49:33.145799+00	2026-05-07 02:28:00.113+00	2026-05-07 02:28:00.113+00
variant_01KR020ETH0T07AXYY7TVZZPXB	pset_01KR020F06YAP3ADDTM8Z9DP6V	pvps_01KR020F378CN9QXSV0Y7WEAWD	2026-05-07 01:49:33.145799+00	2026-05-07 02:28:00.113+00	2026-05-07 02:28:00.113+00
variant_01KR020ETHACSVTSE4AB5R606E	pset_01KR020F079T4D5S2ZQ9VWQN79	pvps_01KR020F375V3369DG6JCPD3EC	2026-05-07 01:49:33.145799+00	2026-05-07 02:28:00.113+00	2026-05-07 02:28:00.113+00
variant_01KR020ETHJ6QF5WWBNT7S8C74	pset_01KR020F06NQX7565A9HFRT3EG	pvps_01KR020F37KPRMBMCZX5PBMYK3	2026-05-07 01:49:33.145799+00	2026-05-07 02:28:02.989+00	2026-05-07 02:28:02.989+00
\.


--
-- Data for Name: product_variant_product_image; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_product_image (id, variant_id, image_id, created_at, updated_at, deleted_at) FROM stdin;
pvpi_01KR26H5841MZAC9ZEV7VT3F0A	variant_01KR26GH9FHCS47X4NKJ2100PV	img_01KR26GH37QK3XRD9C2VX24HA1	2026-05-07 21:47:03.301+00	2026-05-07 21:47:03.301+00	\N
pvpi_01KR26HSS8FKFZ69Q7MNFJTT15	variant_01KR26GH9F4XTCVJ4RM405AZ6W	img_01KR26GH37252JFAF1AWJYTESD	2026-05-07 21:47:24.328+00	2026-05-07 21:47:24.328+00	\N
pvpi_01KR26JK5JGGGZ5FRMGKHXA147	variant_01KR26GH9G01H235TN94XZ14T7	img_01KR26GH37XX7BV8ZP5QME3ST5	2026-05-07 21:47:50.322+00	2026-05-07 21:47:50.322+00	\N
pvpi_01KR26K3WHFWQ992EEBFHNCCFS	variant_01KR26GH9GB74FMJSRCME1J1Z7	img_01KR26GH37143X38PJE2EFAP87	2026-05-07 21:48:07.443+00	2026-05-07 21:48:07.443+00	\N
pvpi_01KR2AASYG2EJBZEXTV813CSW0	variant_01KR2AAAZKNZPEQ4693H2RM8Z5	img_01KR2AAAW021WAQAXP49J6Q6AC	2026-05-07 22:53:29.425+00	2026-05-07 22:53:29.425+00	\N
pvpi_01KR2AB90VN47TQPSNYTAXTXFK	variant_01KR2AAAZKNST690FATR7E6A2R	img_01KR2AAAW0VRNXPZ0HGQYSARKN	2026-05-07 22:53:44.859+00	2026-05-07 22:53:44.859+00	\N
pvpi_01KR2ABPJWEYBFPDNVE934BJCZ	variant_01KR2AAAZM5K2Y3TBDHBR6QDDF	img_01KR2AAAW0XZJCKJ2DSKB2T2D5	2026-05-07 22:53:58.749+00	2026-05-07 22:53:58.749+00	\N
pvpi_01KR2AC5534SJXX3838F3RWPF0	variant_01KR2AAAZM3V4X6SRT2RNP7K35	img_01KR2AAAW0685Z1RR7Q9CZTQY2	2026-05-07 22:54:13.668+00	2026-05-07 22:54:13.668+00	\N
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion (id, code, campaign_id, is_automatic, type, created_at, updated_at, deleted_at, status, is_tax_inclusive, "limit", used, metadata) FROM stdin;
\.


--
-- Data for Name: promotion_application_method; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_application_method (id, value, raw_value, max_quantity, apply_to_quantity, buy_rules_min_quantity, type, target_type, allocation, promotion_id, created_at, updated_at, deleted_at, currency_code) FROM stdin;
\.


--
-- Data for Name: promotion_campaign; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_campaign (id, name, description, campaign_identifier, starts_at, ends_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_campaign_budget (id, type, campaign_id, "limit", raw_limit, used, raw_used, created_at, updated_at, deleted_at, currency_code, attribute) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_campaign_budget_usage (id, attribute_value, used, budget_id, raw_used, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_promotion_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_promotion_rule (promotion_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: promotion_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_rule (id, description, attribute, operator, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_rule_value; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_rule_value (id, promotion_rule_id, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: property_label; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.property_label (id, entity, property, label, description, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: provider_identity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.provider_identity (id, entity_id, provider, auth_identity_id, user_metadata, provider_metadata, created_at, updated_at, deleted_at) FROM stdin;
01KQQGQTDHK7AGQWYDA4AM1528	iyad@eltifi.com	emailpass	authid_01KQQGQTDHRQQ1E49BJW2QXXQK	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAfDM8V+iXav/YzmZcJLcu5yvFgKHexUWhTENcsU4aQVj8FwEoBywnfs54XTZBZD/6HPodeQJLX5zFjvpcl+t5981sK3IgeWCCjUfMHUlCbva"}	2026-05-03 18:13:48.593+00	2026-05-03 18:13:48.593+00	\N
\.


--
-- Data for Name: publishable_api_key_sales_channel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publishable_api_key_sales_channel (publishable_key_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
apk_01KQPJ7FZ41ZTCA7ZTJQG0TPS7	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	pksc_01KQPJ7FZETX1GQ9TDCCT9HBC1	2026-05-03 09:20:36.33241+00	2026-05-03 09:20:36.33241+00	\N
apk_01KQPHSEH4N8PF3KH85WCXVKSN	sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	pksc_01KQPHSEHGMF9V1FG598QJAQ10	2026-05-03 09:12:56.111823+00	2026-05-07 03:15:00.669+00	2026-05-07 03:15:00.669+00
\.


--
-- Data for Name: refund; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refund (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata, refund_reason_id, note) FROM stdin;
\.


--
-- Data for Name: refund_reason; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refund_reason (id, label, description, metadata, created_at, updated_at, deleted_at, code) FROM stdin;
refr_01KQPHS9BJYF3WS0CC6HNP888R	Shipping Issue	Refund due to lost, delayed, or misdelivered shipment	\N	2026-05-03 09:12:50.691319+00	2026-05-03 09:12:50.691319+00	\N	shipping_issue
refr_01KQPHS9BK5A2PEYJBRGF6VH4M	Customer Care Adjustment	Refund given as goodwill or compensation for inconvenience	\N	2026-05-03 09:12:50.691319+00	2026-05-03 09:12:50.691319+00	\N	customer_care_adjustment
refr_01KQPHS9BKZK7CYWHR2CFN3ET7	Pricing Error	Refund to correct an overcharge, missing discount, or incorrect price	\N	2026-05-03 09:12:50.691319+00	2026-05-03 09:12:50.691319+00	\N	pricing_error
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.region (id, name, currency_code, metadata, created_at, updated_at, deleted_at, automatic_taxes) FROM stdin;
reg_01KQPHSEJPZDMT8EQSZPG1VX8A	Europe	eur	\N	2026-05-03 09:12:56.157+00	2026-05-07 03:18:10.406+00	2026-05-07 03:18:10.404+00	t
reg_01KR074QV3K2MQR2HSR2MWXZK5	Florida	usd	\N	2026-05-07 03:19:16.08+00	2026-05-07 03:19:16.08+00	\N	t
\.


--
-- Data for Name: region_country; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.region_country (iso_2, iso_3, num_code, name, display_name, region_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
af	afg	004	AFGHANISTAN	Afghanistan	\N	\N	2026-05-03 09:12:55.13+00	2026-05-03 09:12:55.13+00	\N
al	alb	008	ALBANIA	Albania	\N	\N	2026-05-03 09:12:55.13+00	2026-05-03 09:12:55.13+00	\N
dz	dza	012	ALGERIA	Algeria	\N	\N	2026-05-03 09:12:55.13+00	2026-05-03 09:12:55.13+00	\N
as	asm	016	AMERICAN SAMOA	American Samoa	\N	\N	2026-05-03 09:12:55.13+00	2026-05-03 09:12:55.13+00	\N
ad	and	020	ANDORRA	Andorra	\N	\N	2026-05-03 09:12:55.13+00	2026-05-03 09:12:55.13+00	\N
ao	ago	024	ANGOLA	Angola	\N	\N	2026-05-03 09:12:55.13+00	2026-05-03 09:12:55.13+00	\N
ai	aia	660	ANGUILLA	Anguilla	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
aq	ata	010	ANTARCTICA	Antarctica	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ag	atg	028	ANTIGUA AND BARBUDA	Antigua and Barbuda	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ar	arg	032	ARGENTINA	Argentina	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
am	arm	051	ARMENIA	Armenia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
aw	abw	533	ARUBA	Aruba	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
au	aus	036	AUSTRALIA	Australia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
at	aut	040	AUSTRIA	Austria	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
az	aze	031	AZERBAIJAN	Azerbaijan	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bs	bhs	044	BAHAMAS	Bahamas	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bh	bhr	048	BAHRAIN	Bahrain	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bd	bgd	050	BANGLADESH	Bangladesh	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bb	brb	052	BARBADOS	Barbados	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
by	blr	112	BELARUS	Belarus	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
be	bel	056	BELGIUM	Belgium	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bz	blz	084	BELIZE	Belize	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bj	ben	204	BENIN	Benin	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bm	bmu	060	BERMUDA	Bermuda	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bt	btn	064	BHUTAN	Bhutan	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bo	bol	068	BOLIVIA	Bolivia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bq	bes	535	BONAIRE, SINT EUSTATIUS AND SABA	Bonaire, Sint Eustatius and Saba	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ba	bih	070	BOSNIA AND HERZEGOVINA	Bosnia and Herzegovina	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bw	bwa	072	BOTSWANA	Botswana	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bv	bvd	074	BOUVET ISLAND	Bouvet Island	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
br	bra	076	BRAZIL	Brazil	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
io	iot	086	BRITISH INDIAN OCEAN TERRITORY	British Indian Ocean Territory	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bn	brn	096	BRUNEI DARUSSALAM	Brunei Darussalam	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bg	bgr	100	BULGARIA	Bulgaria	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bf	bfa	854	BURKINA FASO	Burkina Faso	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
bi	bdi	108	BURUNDI	Burundi	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
kh	khm	116	CAMBODIA	Cambodia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cm	cmr	120	CAMEROON	Cameroon	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ca	can	124	CANADA	Canada	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cv	cpv	132	CAPE VERDE	Cape Verde	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ky	cym	136	CAYMAN ISLANDS	Cayman Islands	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cf	caf	140	CENTRAL AFRICAN REPUBLIC	Central African Republic	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
td	tcd	148	CHAD	Chad	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cl	chl	152	CHILE	Chile	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cn	chn	156	CHINA	China	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cx	cxr	162	CHRISTMAS ISLAND	Christmas Island	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cc	cck	166	COCOS (KEELING) ISLANDS	Cocos (Keeling) Islands	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
co	col	170	COLOMBIA	Colombia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
km	com	174	COMOROS	Comoros	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cg	cog	178	CONGO	Congo	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cd	cod	180	CONGO, THE DEMOCRATIC REPUBLIC OF THE	Congo, the Democratic Republic of the	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ck	cok	184	COOK ISLANDS	Cook Islands	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cr	cri	188	COSTA RICA	Costa Rica	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ci	civ	384	COTE D'IVOIRE	Cote D'Ivoire	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
hr	hrv	191	CROATIA	Croatia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cu	cub	192	CUBA	Cuba	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cw	cuw	531	CURAÇAO	Curaçao	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cy	cyp	196	CYPRUS	Cyprus	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
cz	cze	203	CZECH REPUBLIC	Czech Republic	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
dj	dji	262	DJIBOUTI	Djibouti	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
dm	dma	212	DOMINICA	Dominica	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
do	dom	214	DOMINICAN REPUBLIC	Dominican Republic	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ec	ecu	218	ECUADOR	Ecuador	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
eg	egy	818	EGYPT	Egypt	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
sv	slv	222	EL SALVADOR	El Salvador	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gq	gnq	226	EQUATORIAL GUINEA	Equatorial Guinea	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
er	eri	232	ERITREA	Eritrea	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ee	est	233	ESTONIA	Estonia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
et	eth	231	ETHIOPIA	Ethiopia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
fk	flk	238	FALKLAND ISLANDS (MALVINAS)	Falkland Islands (Malvinas)	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
fo	fro	234	FAROE ISLANDS	Faroe Islands	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
fj	fji	242	FIJI	Fiji	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
fi	fin	246	FINLAND	Finland	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gf	guf	254	FRENCH GUIANA	French Guiana	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
pf	pyf	258	FRENCH POLYNESIA	French Polynesia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
tf	atf	260	FRENCH SOUTHERN TERRITORIES	French Southern Territories	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ga	gab	266	GABON	Gabon	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gm	gmb	270	GAMBIA	Gambia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ge	geo	268	GEORGIA	Georgia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gh	gha	288	GHANA	Ghana	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gi	gib	292	GIBRALTAR	Gibraltar	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gr	grc	300	GREECE	Greece	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gl	grl	304	GREENLAND	Greenland	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gd	grd	308	GRENADA	Grenada	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gp	glp	312	GUADELOUPE	Guadeloupe	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gu	gum	316	GUAM	Guam	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gt	gtm	320	GUATEMALA	Guatemala	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gg	ggy	831	GUERNSEY	Guernsey	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gn	gin	324	GUINEA	Guinea	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gw	gnb	624	GUINEA-BISSAU	Guinea-Bissau	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
gy	guy	328	GUYANA	Guyana	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ht	hti	332	HAITI	Haiti	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
hm	hmd	334	HEARD ISLAND AND MCDONALD ISLANDS	Heard Island And Mcdonald Islands	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
va	vat	336	HOLY SEE (VATICAN CITY STATE)	Holy See (Vatican City State)	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
hn	hnd	340	HONDURAS	Honduras	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
hk	hkg	344	HONG KONG	Hong Kong	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
hu	hun	348	HUNGARY	Hungary	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
is	isl	352	ICELAND	Iceland	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
in	ind	356	INDIA	India	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
id	idn	360	INDONESIA	Indonesia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ir	irn	364	IRAN, ISLAMIC REPUBLIC OF	Iran, Islamic Republic of	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
iq	irq	368	IRAQ	Iraq	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ie	irl	372	IRELAND	Ireland	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
im	imn	833	ISLE OF MAN	Isle Of Man	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
il	isr	376	ISRAEL	Israel	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
jm	jam	388	JAMAICA	Jamaica	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
jp	jpn	392	JAPAN	Japan	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
je	jey	832	JERSEY	Jersey	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
jo	jor	400	JORDAN	Jordan	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
kz	kaz	398	KAZAKHSTAN	Kazakhstan	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ke	ken	404	KENYA	Kenya	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ki	kir	296	KIRIBATI	Kiribati	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
kp	prk	408	KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF	Korea, Democratic People's Republic of	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
kr	kor	410	KOREA, REPUBLIC OF	Korea, Republic of	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
xk	xkx	900	KOSOVO	Kosovo	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
kw	kwt	414	KUWAIT	Kuwait	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
kg	kgz	417	KYRGYZSTAN	Kyrgyzstan	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
la	lao	418	LAO PEOPLE'S DEMOCRATIC REPUBLIC	Lao People's Democratic Republic	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
lv	lva	428	LATVIA	Latvia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
lb	lbn	422	LEBANON	Lebanon	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ls	lso	426	LESOTHO	Lesotho	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
lr	lbr	430	LIBERIA	Liberia	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.131+00	\N
ly	lby	434	LIBYA	Libya	\N	\N	2026-05-03 09:12:55.131+00	2026-05-03 09:12:55.132+00	\N
li	lie	438	LIECHTENSTEIN	Liechtenstein	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
lt	ltu	440	LITHUANIA	Lithuania	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
lu	lux	442	LUXEMBOURG	Luxembourg	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mo	mac	446	MACAO	Macao	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mg	mdg	450	MADAGASCAR	Madagascar	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mw	mwi	454	MALAWI	Malawi	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
my	mys	458	MALAYSIA	Malaysia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mv	mdv	462	MALDIVES	Maldives	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ml	mli	466	MALI	Mali	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mt	mlt	470	MALTA	Malta	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mh	mhl	584	MARSHALL ISLANDS	Marshall Islands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mq	mtq	474	MARTINIQUE	Martinique	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mr	mrt	478	MAURITANIA	Mauritania	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mu	mus	480	MAURITIUS	Mauritius	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
yt	myt	175	MAYOTTE	Mayotte	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mx	mex	484	MEXICO	Mexico	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
fm	fsm	583	MICRONESIA, FEDERATED STATES OF	Micronesia, Federated States of	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
md	mda	498	MOLDOVA, REPUBLIC OF	Moldova, Republic of	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mc	mco	492	MONACO	Monaco	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mn	mng	496	MONGOLIA	Mongolia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
me	mne	499	MONTENEGRO	Montenegro	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ms	msr	500	MONTSERRAT	Montserrat	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ma	mar	504	MOROCCO	Morocco	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mz	moz	508	MOZAMBIQUE	Mozambique	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mm	mmr	104	MYANMAR	Myanmar	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
na	nam	516	NAMIBIA	Namibia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
nr	nru	520	NAURU	Nauru	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
np	npl	524	NEPAL	Nepal	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
nl	nld	528	NETHERLANDS	Netherlands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
nc	ncl	540	NEW CALEDONIA	New Caledonia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
nz	nzl	554	NEW ZEALAND	New Zealand	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ni	nic	558	NICARAGUA	Nicaragua	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ne	ner	562	NIGER	Niger	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ng	nga	566	NIGERIA	Nigeria	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
nu	niu	570	NIUE	Niue	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
nf	nfk	574	NORFOLK ISLAND	Norfolk Island	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mk	mkd	807	NORTH MACEDONIA	North Macedonia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mp	mnp	580	NORTHERN MARIANA ISLANDS	Northern Mariana Islands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
no	nor	578	NORWAY	Norway	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
om	omn	512	OMAN	Oman	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pk	pak	586	PAKISTAN	Pakistan	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pw	plw	585	PALAU	Palau	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ps	pse	275	PALESTINIAN TERRITORY, OCCUPIED	Palestinian Territory, Occupied	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pa	pan	591	PANAMA	Panama	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pg	png	598	PAPUA NEW GUINEA	Papua New Guinea	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
py	pry	600	PARAGUAY	Paraguay	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pe	per	604	PERU	Peru	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ph	phl	608	PHILIPPINES	Philippines	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pn	pcn	612	PITCAIRN	Pitcairn	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pl	pol	616	POLAND	Poland	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pt	prt	620	PORTUGAL	Portugal	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pr	pri	630	PUERTO RICO	Puerto Rico	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
qa	qat	634	QATAR	Qatar	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
re	reu	638	REUNION	Reunion	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ro	rom	642	ROMANIA	Romania	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ru	rus	643	RUSSIAN FEDERATION	Russian Federation	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
rw	rwa	646	RWANDA	Rwanda	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
bl	blm	652	SAINT BARTHÉLEMY	Saint Barthélemy	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sh	shn	654	SAINT HELENA	Saint Helena	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
kn	kna	659	SAINT KITTS AND NEVIS	Saint Kitts and Nevis	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
lc	lca	662	SAINT LUCIA	Saint Lucia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
mf	maf	663	SAINT MARTIN (FRENCH PART)	Saint Martin (French part)	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
pm	spm	666	SAINT PIERRE AND MIQUELON	Saint Pierre and Miquelon	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
vc	vct	670	SAINT VINCENT AND THE GRENADINES	Saint Vincent and the Grenadines	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ws	wsm	882	SAMOA	Samoa	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sm	smr	674	SAN MARINO	San Marino	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
st	stp	678	SAO TOME AND PRINCIPE	Sao Tome and Principe	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sa	sau	682	SAUDI ARABIA	Saudi Arabia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sn	sen	686	SENEGAL	Senegal	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
rs	srb	688	SERBIA	Serbia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sc	syc	690	SEYCHELLES	Seychelles	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sl	sle	694	SIERRA LEONE	Sierra Leone	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sg	sgp	702	SINGAPORE	Singapore	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sx	sxm	534	SINT MAARTEN	Sint Maarten	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sk	svk	703	SLOVAKIA	Slovakia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
si	svn	705	SLOVENIA	Slovenia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sb	slb	090	SOLOMON ISLANDS	Solomon Islands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
so	som	706	SOMALIA	Somalia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
za	zaf	710	SOUTH AFRICA	South Africa	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
gs	sgs	239	SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS	South Georgia and the South Sandwich Islands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ss	ssd	728	SOUTH SUDAN	South Sudan	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
lk	lka	144	SRI LANKA	Sri Lanka	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sd	sdn	729	SUDAN	Sudan	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sr	sur	740	SURINAME	Suriname	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sj	sjm	744	SVALBARD AND JAN MAYEN	Svalbard and Jan Mayen	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sz	swz	748	SWAZILAND	Swaziland	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ch	che	756	SWITZERLAND	Switzerland	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
sy	syr	760	SYRIAN ARAB REPUBLIC	Syrian Arab Republic	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tw	twn	158	TAIWAN, PROVINCE OF CHINA	Taiwan, Province of China	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tj	tjk	762	TAJIKISTAN	Tajikistan	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tz	tza	834	TANZANIA, UNITED REPUBLIC OF	Tanzania, United Republic of	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
th	tha	764	THAILAND	Thailand	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tl	tls	626	TIMOR LESTE	Timor Leste	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tg	tgo	768	TOGO	Togo	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tk	tkl	772	TOKELAU	Tokelau	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
to	ton	776	TONGA	Tonga	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tt	tto	780	TRINIDAD AND TOBAGO	Trinidad and Tobago	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tn	tun	788	TUNISIA	Tunisia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tr	tur	792	TURKEY	Turkey	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tm	tkm	795	TURKMENISTAN	Turkmenistan	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tc	tca	796	TURKS AND CAICOS ISLANDS	Turks and Caicos Islands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
tv	tuv	798	TUVALU	Tuvalu	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ug	uga	800	UGANDA	Uganda	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ua	ukr	804	UKRAINE	Ukraine	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ae	are	784	UNITED ARAB EMIRATES	United Arab Emirates	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
um	umi	581	UNITED STATES MINOR OUTLYING ISLANDS	United States Minor Outlying Islands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
uy	ury	858	URUGUAY	Uruguay	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
uz	uzb	860	UZBEKISTAN	Uzbekistan	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
vu	vut	548	VANUATU	Vanuatu	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ve	ven	862	VENEZUELA	Venezuela	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
vn	vnm	704	VIET NAM	Viet Nam	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
vg	vgb	092	VIRGIN ISLANDS, BRITISH	Virgin Islands, British	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
vi	vir	850	VIRGIN ISLANDS, U.S.	Virgin Islands, U.S.	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
wf	wlf	876	WALLIS AND FUTUNA	Wallis and Futuna	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
eh	esh	732	WESTERN SAHARA	Western Sahara	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ye	yem	887	YEMEN	Yemen	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
zm	zmb	894	ZAMBIA	Zambia	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
zw	zwe	716	ZIMBABWE	Zimbabwe	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
ax	ala	248	ÅLAND ISLANDS	Åland Islands	\N	\N	2026-05-03 09:12:55.132+00	2026-05-03 09:12:55.132+00	\N
dk	dnk	208	DENMARK	Denmark	\N	\N	2026-05-03 09:12:55.131+00	2026-05-07 03:18:10.425+00	\N
fr	fra	250	FRANCE	France	\N	\N	2026-05-03 09:12:55.131+00	2026-05-07 03:18:10.425+00	\N
de	deu	276	GERMANY	Germany	\N	\N	2026-05-03 09:12:55.131+00	2026-05-07 03:18:10.425+00	\N
it	ita	380	ITALY	Italy	\N	\N	2026-05-03 09:12:55.131+00	2026-05-07 03:18:10.425+00	\N
es	esp	724	SPAIN	Spain	\N	\N	2026-05-03 09:12:55.132+00	2026-05-07 03:18:10.425+00	\N
se	swe	752	SWEDEN	Sweden	\N	\N	2026-05-03 09:12:55.132+00	2026-05-07 03:18:10.425+00	\N
gb	gbr	826	UNITED KINGDOM	United Kingdom	\N	\N	2026-05-03 09:12:55.132+00	2026-05-07 03:18:10.425+00	\N
us	usa	840	UNITED STATES	United States	reg_01KR074QV3K2MQR2HSR2MWXZK5	\N	2026-05-03 09:12:55.132+00	2026-05-07 03:19:16.08+00	\N
\.


--
-- Data for Name: region_payment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.region_payment_provider (region_id, payment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
reg_01KQPHSEJPZDMT8EQSZPG1VX8A	pp_system_default	regpp_01KQPHSEKGHKP9Z2HAJ3EBW4B3	2026-05-03 09:12:56.175599+00	2026-05-07 03:18:10.437+00	2026-05-07 03:18:10.436+00
reg_01KR074QV3K2MQR2HSR2MWXZK5	pp_system_default	regpp_01KR074QWD74T0152K4QSWNKG8	2026-05-07 03:19:16.101771+00	2026-05-07 03:19:16.101771+00	\N
\.


--
-- Data for Name: reservation_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reservation_item (id, created_at, updated_at, deleted_at, line_item_id, location_id, quantity, external_id, description, created_by, metadata, inventory_item_id, allow_backorder, raw_quantity) FROM stdin;
\.


--
-- Data for Name: return; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return (id, order_id, claim_id, exchange_id, order_version, display_id, status, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, received_at, canceled_at, location_id, requested_at, created_by) FROM stdin;
\.


--
-- Data for Name: return_fulfillment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return_fulfillment (return_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: return_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return_item (id, return_id, reason_id, item_id, quantity, raw_quantity, received_quantity, raw_received_quantity, note, metadata, created_at, updated_at, deleted_at, damaged_quantity, raw_damaged_quantity) FROM stdin;
\.


--
-- Data for Name: return_reason; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return_reason (id, value, label, description, metadata, parent_return_reason_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sales_channel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_channel (id, name, description, is_disabled, metadata, created_at, updated_at, deleted_at) FROM stdin;
sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	Bayblaze Storefront	Default sales channel for bayblaze-storefront	f	\N	2026-05-03 09:20:36.311+00	2026-05-03 09:20:36.311+00	\N
sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	Default Sales Channel	Created by Medusa	f	\N	2026-05-03 09:12:56.091+00	2026-05-07 03:15:00.648+00	2026-05-07 03:15:00.646+00
\.


--
-- Data for Name: sales_channel_stock_location; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_channel_stock_location (sales_channel_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
sc_01KQPHSEGVCXJFZE4DFPWW9TJ8	sloc_01KQPHSEM3J9F24P547ZY11ENJ	scloc_01KQPHSEQKST2NX5KSY3PSRS3S	2026-05-03 09:12:56.306441+00	2026-05-07 03:15:00.666+00	2026-05-07 03:15:00.666+00
\.


--
-- Data for Name: script_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.script_migrations (id, script_name, created_at, finished_at) FROM stdin;
1	migrate-normalize-currency-codes-normalization.js	2026-05-03 09:12:55.344617+00	2026-05-03 09:12:55.384998+00
2	migrate-product-shipping-profile.js	2026-05-03 09:12:56.034586+00	2026-05-03 09:12:56.057517+00
3	migrate-tax-region-provider.js	2026-05-03 09:12:56.060293+00	2026-05-03 09:12:56.067022+00
4	initial-data-seed.ts	2026-05-03 09:12:56.082142+00	2026-05-03 09:12:56.540057+00
\.


--
-- Data for Name: service_zone; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_zone (id, name, metadata, fulfillment_set_id, created_at, updated_at, deleted_at) FROM stdin;
serzo_01KQPHSEMMNKF5J38RE8FJBQYV	Europe	\N	fuset_01KQPHSEMM1F56YMCQYP82RARJ	2026-05-03 09:12:56.212+00	2026-05-07 03:52:28.4+00	2026-05-07 03:52:28.395+00
serzo_01KR0959J9HRS439K810RP978Y	Tampa	\N	fuset_01KR0944SBGKK3GSMA8Q0HFY5B	2026-05-07 03:54:31.37+00	2026-05-07 03:54:31.37+00	\N
\.


--
-- Data for Name: shipping_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option (id, name, price_type, service_zone_id, shipping_profile_id, provider_id, data, metadata, shipping_option_type_id, created_at, updated_at, deleted_at) FROM stdin;
so_01KQPHSEP1H50A6KB81DDHCC3N	Standard Shipping	flat	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	sp_01KQPHSEFM77XP8JWGTBSQZPXB	manual_manual	\N	\N	sotype_01KQPHSEP0RHDV97W02K7FZBAK	2026-05-03 09:12:56.258+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
so_01KQPHSEP1Q6Y4A271A6J2RGT9	Express Shipping	flat	serzo_01KQPHSEMMNKF5J38RE8FJBQYV	sp_01KQPHSEFM77XP8JWGTBSQZPXB	manual_manual	\N	\N	sotype_01KQPHSEP10CFF92SGYEP83QSA	2026-05-03 09:12:56.258+00	2026-05-07 03:52:28.412+00	2026-05-07 03:52:28.395+00
\.


--
-- Data for Name: shipping_option_price_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option_price_set (shipping_option_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
so_01KQPHSEP1H50A6KB81DDHCC3N	pset_01KQPHSEPGM621N1BRADDQTZVB	sops_01KQPHSEQBJSAKY3AFCGE1G43C	2026-05-03 09:12:56.29881+00	2026-05-07 03:52:28.428+00	2026-05-07 03:52:28.427+00
so_01KQPHSEP1Q6Y4A271A6J2RGT9	pset_01KQPHSEPHREJ626MJP27FZS6A	sops_01KQPHSEQCRZHBBVCS4BJAMAET	2026-05-03 09:12:56.29881+00	2026-05-07 03:52:28.428+00	2026-05-07 03:52:28.427+00
\.


--
-- Data for Name: shipping_option_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option_rule (id, attribute, operator, value, shipping_option_id, created_at, updated_at, deleted_at) FROM stdin;
sorul_01KQPHSEP1WQYX6422SVQ1K8SN	enabled_in_store	eq	"true"	so_01KQPHSEP1H50A6KB81DDHCC3N	2026-05-03 09:12:56.258+00	2026-05-07 03:52:28.421+00	2026-05-07 03:52:28.395+00
sorul_01KQPHSEP1S55JG5GN8PF3TYXP	is_return	eq	"false"	so_01KQPHSEP1H50A6KB81DDHCC3N	2026-05-03 09:12:56.258+00	2026-05-07 03:52:28.421+00	2026-05-07 03:52:28.395+00
sorul_01KQPHSEP16W6S936G01MK7JDF	enabled_in_store	eq	"true"	so_01KQPHSEP1Q6Y4A271A6J2RGT9	2026-05-03 09:12:56.258+00	2026-05-07 03:52:28.421+00	2026-05-07 03:52:28.395+00
sorul_01KQPHSEP1KPMAEW3K03A2XJ99	is_return	eq	"false"	so_01KQPHSEP1Q6Y4A271A6J2RGT9	2026-05-03 09:12:56.258+00	2026-05-07 03:52:28.421+00	2026-05-07 03:52:28.395+00
\.


--
-- Data for Name: shipping_option_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option_type (id, label, description, code, created_at, updated_at, deleted_at) FROM stdin;
sotype_01KQPHSEP0RHDV97W02K7FZBAK	Standard	Ship in 2-3 days.	standard	2026-05-03 09:12:56.257+00	2026-05-03 09:12:56.257+00	\N
sotype_01KQPHSEP10CFF92SGYEP83QSA	Express	Ship in 24 hours.	express	2026-05-03 09:12:56.258+00	2026-05-03 09:12:56.258+00	\N
\.


--
-- Data for Name: shipping_profile; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_profile (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
sp_01KQPHSEFM77XP8JWGTBSQZPXB	Default Shipping Profile	default	\N	2026-05-03 09:12:56.052+00	2026-05-03 09:12:56.052+00	\N
\.


--
-- Data for Name: stock_location; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_location (id, created_at, updated_at, deleted_at, name, address_id, metadata) FROM stdin;
sloc_01KQPHSEM3J9F24P547ZY11ENJ	2026-05-03 09:12:56.196+00	2026-05-07 03:52:28.352+00	2026-05-07 03:52:28.35+00	European Warehouse	laddr_01KQPHSEM3BVPJXFCMWG1KSRDR	\N
sloc_01KR093X1HRT484K9N255ZE7BD	2026-05-07 03:53:45.781+00	2026-05-07 03:53:45.781+00	\N	Iyad Eltifi	laddr_01KR093X1HZTFHZB25AVS2H8QM	\N
\.


--
-- Data for Name: stock_location_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_location_address (id, created_at, updated_at, deleted_at, address_1, address_2, company, city, country_code, phone, province, postal_code, metadata) FROM stdin;
laddr_01KQPHSEM3BVPJXFCMWG1KSRDR	2026-05-03 09:12:56.195+00	2026-05-07 03:52:28.376+00	2026-05-07 03:52:28.35+00		\N	\N	Copenhagen	DK	\N	\N	\N	\N
laddr_01KR093X1HZTFHZB25AVS2H8QM	2026-05-07 03:53:45.78+00	2026-05-07 03:53:45.78+00	\N	13702 42nd St			Tampa	us	8136386858	FL	33613	\N
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.store (id, name, default_sales_channel_id, default_region_id, default_location_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
store_01KQPJ7FZWE1F98D3EKPXKEG0W	Bayblaze	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	\N	\N	\N	2026-05-03 09:20:36.344951+00	2026-05-03 09:20:36.344951+00	\N
store_01KQPHSEHWETD65JHF1W9B8B4Q	BAYBLAZE	sc_01KQPJ7FYQ8R8704TJ3KZD8Y45	\N	\N	\N	2026-05-03 09:12:56.122631+00	2026-05-03 09:12:56.122631+00	\N
\.


--
-- Data for Name: store_currency; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.store_currency (id, currency_code, is_default, store_id, created_at, updated_at, deleted_at) FROM stdin;
stocur_01KQPJ7G00VJTAHQWM91E2SX9A	usd	t	store_01KQPJ7FZWE1F98D3EKPXKEG0W	2026-05-03 09:20:36.344951+00	2026-05-03 09:20:36.344951+00	\N
stocur_01KR071KRVEF3PZ98G2JEMJ660	usd	t	store_01KQPHSEHWETD65JHF1W9B8B4Q	2026-05-07 03:17:33.581234+00	2026-05-07 03:17:33.581234+00	\N
\.


--
-- Data for Name: store_locale; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.store_locale (id, locale_code, store_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
tp_system	t	2026-05-03 09:12:55.151+00	2026-05-03 09:12:55.151+00	\N
\.


--
-- Data for Name: tax_rate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_rate (id, rate, code, name, is_default, is_combinable, tax_region_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
txr_01KR07EMXH3XM0Q9AK1HKK7ZPN	7.5	FL-HILLSBOROUGH-SALES	Hillsborough	t	f	txreg_01KR07EMX0M0CB5SG9GARXX1VD	\N	2026-05-07 03:24:40.753+00	2026-05-07 03:24:40.753+00	user_01KQQGQTAXWETD7Q63QR2Z0EYE	\N
\.


--
-- Data for Name: tax_rate_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_rate_rule (id, tax_rate_id, reference_id, reference, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_region; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_region (id, provider_id, country_code, province_code, parent_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
txreg_01KQPHSEKRF11KMSC4P9CFSMZS	tp_system	de	\N	\N	\N	2026-05-03 09:12:56.185+00	2026-05-07 03:19:47.505+00	\N	2026-05-07 03:19:47.503+00
txreg_01KQPHSEKRHRGASSHYG9HC9FS9	tp_system	dk	\N	\N	\N	2026-05-03 09:12:56.185+00	2026-05-07 03:19:49.889+00	\N	2026-05-07 03:19:49.889+00
txreg_01KQPHSEKRT6SC9WE1TVTAQXBP	tp_system	es	\N	\N	\N	2026-05-03 09:12:56.185+00	2026-05-07 03:19:55.145+00	\N	2026-05-07 03:19:55.144+00
txreg_01KQPHSEKR9MD3JKRXEEWN7D14	tp_system	fr	\N	\N	\N	2026-05-03 09:12:56.185+00	2026-05-07 03:19:58.517+00	\N	2026-05-07 03:19:58.516+00
txreg_01KQPHSEKR4XPXSD604Z79BJ6Z	tp_system	gb	\N	\N	\N	2026-05-03 09:12:56.185+00	2026-05-07 03:20:01.246+00	\N	2026-05-07 03:20:01.246+00
txreg_01KQPHSEKRJB7VDAJZFPWENJNC	tp_system	it	\N	\N	\N	2026-05-03 09:12:56.185+00	2026-05-07 03:20:04.174+00	\N	2026-05-07 03:20:04.174+00
txreg_01KQPHSEKRTJBEFDVG1626TTHR	tp_system	se	\N	\N	\N	2026-05-03 09:12:56.185+00	2026-05-07 03:20:09.582+00	\N	2026-05-07 03:20:09.581+00
txreg_01KR07EMX0M0CB5SG9GARXX1VD	tp_system	us	\N	\N	\N	2026-05-07 03:24:40.737+00	2026-05-07 03:24:40.737+00	user_01KQQGQTAXWETD7Q63QR2Z0EYE	\N
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."user" (id, first_name, last_name, email, avatar_url, metadata, created_at, updated_at, deleted_at) FROM stdin;
user_01KQQGQTAXWETD7Q63QR2Z0EYE	\N	\N	iyad@eltifi.com	\N	\N	2026-05-03 18:13:48.509+00	2026-05-03 18:13:48.509+00	\N
\.


--
-- Data for Name: user_preference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_preference (id, user_id, key, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: user_rbac_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_rbac_role (user_id, rbac_role_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: view_configuration; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.view_configuration (id, entity, name, user_id, is_system_default, configuration, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: workflow_execution; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workflow_execution (id, workflow_id, transaction_id, execution, context, state, created_at, updated_at, deleted_at, retention_time, run_id) FROM stdin;
\.


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.link_module_migrations_id_seq', 20, true);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.mikro_orm_migrations_id_seq', 161, true);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_change_action_ordering_seq', 1, false);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_claim_display_id_seq', 1, false);


--
-- Name: order_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_display_id_seq', 1, false);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_exchange_display_id_seq', 1, false);


--
-- Name: return_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.return_display_id_seq', 1, false);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.script_migrations_id_seq', 4, true);


--
-- Name: account_holder account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_holder
    ADD CONSTRAINT account_holder_pkey PRIMARY KEY (id);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: application_method_buy_rules application_method_buy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: application_method_target_rules application_method_target_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY (id);


--
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- Name: cart_address cart_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT cart_address_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item cart_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: cart_payment_collection cart_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_payment_collection
    ADD CONSTRAINT cart_payment_collection_pkey PRIMARY KEY (cart_id, payment_collection_id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_promotion cart_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_promotion
    ADD CONSTRAINT cart_promotion_pkey PRIMARY KEY (cart_id, promotion_id);


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method cart_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: credit_line credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_pkey PRIMARY KEY (id);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (code);


--
-- Name: customer_account_holder customer_account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_account_holder
    ADD CONSTRAINT customer_account_holder_pkey PRIMARY KEY (customer_id, account_holder_id);


--
-- Name: customer_address customer_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (id);


--
-- Name: customer_group_customer customer_group_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_pkey PRIMARY KEY (id);


--
-- Name: customer_group customer_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT customer_group_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_address fulfillment_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_address
    ADD CONSTRAINT fulfillment_address_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_item fulfillment_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_label fulfillment_label_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_pkey PRIMARY KEY (id);


--
-- Name: fulfillment fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_provider fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_provider
    ADD CONSTRAINT fulfillment_provider_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_set fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_set
    ADD CONSTRAINT fulfillment_set_pkey PRIMARY KEY (id);


--
-- Name: geo_zone geo_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);


--
-- Name: inventory_level inventory_level_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_pkey PRIMARY KEY (id);


--
-- Name: invite invite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invite
    ADD CONSTRAINT invite_pkey PRIMARY KEY (id);


--
-- Name: invite_rbac_role invite_rbac_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invite_rbac_role
    ADD CONSTRAINT invite_rbac_role_pkey PRIMARY KEY (invite_id, rbac_role_id);


--
-- Name: link_module_migrations link_module_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_table_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_table_name_key UNIQUE (table_name);


--
-- Name: location_fulfillment_provider location_fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_fulfillment_provider
    ADD CONSTRAINT location_fulfillment_provider_pkey PRIMARY KEY (stock_location_id, fulfillment_provider_id);


--
-- Name: location_fulfillment_set location_fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_fulfillment_set
    ADD CONSTRAINT location_fulfillment_set_pkey PRIMARY KEY (stock_location_id, fulfillment_set_id);


--
-- Name: mikro_orm_migrations mikro_orm_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mikro_orm_migrations
    ADD CONSTRAINT mikro_orm_migrations_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_provider notification_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_provider
    ADD CONSTRAINT notification_provider_pkey PRIMARY KEY (id);


--
-- Name: order_address order_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT order_address_pkey PRIMARY KEY (id);


--
-- Name: order_cart order_cart_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_cart
    ADD CONSTRAINT order_cart_pkey PRIMARY KEY (order_id, cart_id);


--
-- Name: order_change_action order_change_action_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_pkey PRIMARY KEY (id);


--
-- Name: order_change order_change_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item_image order_claim_item_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim_item_image
    ADD CONSTRAINT order_claim_item_image_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item order_claim_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim_item
    ADD CONSTRAINT order_claim_item_pkey PRIMARY KEY (id);


--
-- Name: order_claim order_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim
    ADD CONSTRAINT order_claim_pkey PRIMARY KEY (id);


--
-- Name: order_credit_line order_credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_pkey PRIMARY KEY (id);


--
-- Name: order_exchange_item order_exchange_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_exchange_item
    ADD CONSTRAINT order_exchange_item_pkey PRIMARY KEY (id);


--
-- Name: order_exchange order_exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_exchange
    ADD CONSTRAINT order_exchange_pkey PRIMARY KEY (id);


--
-- Name: order_fulfillment order_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_fulfillment
    ADD CONSTRAINT order_fulfillment_pkey PRIMARY KEY (order_id, fulfillment_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_adjustment order_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_line_item order_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_tax_line order_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_payment_collection order_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payment_collection
    ADD CONSTRAINT order_payment_collection_pkey PRIMARY KEY (order_id, payment_collection_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: order_promotion order_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_promotion
    ADD CONSTRAINT order_promotion_pkey PRIMARY KEY (order_id, promotion_id);


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method order_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method
    ADD CONSTRAINT order_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_shipping order_shipping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_pkey PRIMARY KEY (id);


--
-- Name: order_summary order_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_pkey PRIMARY KEY (id);


--
-- Name: order_transaction order_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_pkey PRIMARY KEY (id);


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_pkey PRIMARY KEY (payment_collection_id, payment_provider_id);


--
-- Name: payment_collection payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection
    ADD CONSTRAINT payment_collection_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: payment_provider payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_provider
    ADD CONSTRAINT payment_provider_pkey PRIMARY KEY (id);


--
-- Name: payment_session payment_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_pkey PRIMARY KEY (id);


--
-- Name: price_list price_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_list
    ADD CONSTRAINT price_list_pkey PRIMARY KEY (id);


--
-- Name: price_list_rule price_list_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_pkey PRIMARY KEY (id);


--
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (id);


--
-- Name: price_preference price_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_preference
    ADD CONSTRAINT price_preference_pkey PRIMARY KEY (id);


--
-- Name: price_rule price_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_pkey PRIMARY KEY (id);


--
-- Name: price_set price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_set
    ADD CONSTRAINT price_set_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_category_product product_category_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_pkey PRIMARY KEY (product_id, product_category_id);


--
-- Name: product_collection product_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT product_collection_pkey PRIMARY KEY (id);


--
-- Name: product_option product_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_pkey PRIMARY KEY (id);


--
-- Name: product_option_value product_option_value_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_sales_channel product_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT product_sales_channel_pkey PRIMARY KEY (product_id, sales_channel_id);


--
-- Name: product_shipping_profile product_shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_shipping_profile
    ADD CONSTRAINT product_shipping_profile_pkey PRIMARY KEY (product_id, shipping_profile_id);


--
-- Name: product_tag product_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tag
    ADD CONSTRAINT product_tag_pkey PRIMARY KEY (id);


--
-- Name: product_tags product_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_pkey PRIMARY KEY (product_id, product_tag_id);


--
-- Name: product_type product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);


--
-- Name: product_variant_inventory_item product_variant_inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_inventory_item
    ADD CONSTRAINT product_variant_inventory_item_pkey PRIMARY KEY (variant_id, inventory_item_id);


--
-- Name: product_variant_option product_variant_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_pkey PRIMARY KEY (variant_id, option_value_id);


--
-- Name: product_variant product_variant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_pkey PRIMARY KEY (id);


--
-- Name: product_variant_price_set product_variant_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_price_set
    ADD CONSTRAINT product_variant_price_set_pkey PRIMARY KEY (variant_id, price_set_id);


--
-- Name: product_variant_product_image product_variant_product_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_pkey PRIMARY KEY (id);


--
-- Name: promotion_application_method promotion_application_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget promotion_campaign_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign promotion_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign
    ADD CONSTRAINT promotion_campaign_pkey PRIMARY KEY (id);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);


--
-- Name: promotion_promotion_rule promotion_promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_pkey PRIMARY KEY (promotion_id, promotion_rule_id);


--
-- Name: promotion_rule promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rule
    ADD CONSTRAINT promotion_rule_pkey PRIMARY KEY (id);


--
-- Name: promotion_rule_value promotion_rule_value_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_pkey PRIMARY KEY (id);


--
-- Name: property_label property_label_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.property_label
    ADD CONSTRAINT property_label_pkey PRIMARY KEY (id);


--
-- Name: provider_identity provider_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_pkey PRIMARY KEY (id);


--
-- Name: publishable_api_key_sales_channel publishable_api_key_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publishable_api_key_sales_channel
    ADD CONSTRAINT publishable_api_key_sales_channel_pkey PRIMARY KEY (publishable_key_id, sales_channel_id);


--
-- Name: refund refund_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_pkey PRIMARY KEY (id);


--
-- Name: refund_reason refund_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_reason
    ADD CONSTRAINT refund_reason_pkey PRIMARY KEY (id);


--
-- Name: region_country region_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_pkey PRIMARY KEY (iso_2);


--
-- Name: region_payment_provider region_payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_payment_provider
    ADD CONSTRAINT region_payment_provider_pkey PRIMARY KEY (region_id, payment_provider_id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: reservation_item reservation_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_pkey PRIMARY KEY (id);


--
-- Name: return_fulfillment return_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_fulfillment
    ADD CONSTRAINT return_fulfillment_pkey PRIMARY KEY (return_id, fulfillment_id);


--
-- Name: return_item return_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT return_item_pkey PRIMARY KEY (id);


--
-- Name: return return_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_pkey PRIMARY KEY (id);


--
-- Name: return_reason return_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_pkey PRIMARY KEY (id);


--
-- Name: sales_channel sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_channel
    ADD CONSTRAINT sales_channel_pkey PRIMARY KEY (id);


--
-- Name: sales_channel_stock_location sales_channel_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_channel_stock_location
    ADD CONSTRAINT sales_channel_stock_location_pkey PRIMARY KEY (sales_channel_id, stock_location_id);


--
-- Name: script_migrations script_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script_migrations
    ADD CONSTRAINT script_migrations_pkey PRIMARY KEY (id);


--
-- Name: service_zone service_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_pkey PRIMARY KEY (id);


--
-- Name: shipping_option shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_price_set shipping_option_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_price_set
    ADD CONSTRAINT shipping_option_price_set_pkey PRIMARY KEY (shipping_option_id, price_set_id);


--
-- Name: shipping_option_rule shipping_option_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_type shipping_option_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_type
    ADD CONSTRAINT shipping_option_type_pkey PRIMARY KEY (id);


--
-- Name: shipping_profile shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_profile
    ADD CONSTRAINT shipping_profile_pkey PRIMARY KEY (id);


--
-- Name: stock_location_address stock_location_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_location_address
    ADD CONSTRAINT stock_location_address_pkey PRIMARY KEY (id);


--
-- Name: stock_location stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_pkey PRIMARY KEY (id);


--
-- Name: store_currency store_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_pkey PRIMARY KEY (id);


--
-- Name: store_locale store_locale_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_pkey PRIMARY KEY (id);


--
-- Name: store store_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);


--
-- Name: tax_provider tax_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_provider
    ADD CONSTRAINT tax_provider_pkey PRIMARY KEY (id);


--
-- Name: tax_rate tax_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT tax_rate_pkey PRIMARY KEY (id);


--
-- Name: tax_rate_rule tax_rate_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT tax_rate_rule_pkey PRIMARY KEY (id);


--
-- Name: tax_region tax_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT tax_region_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_preference user_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preference
    ADD CONSTRAINT user_preference_pkey PRIMARY KEY (id);


--
-- Name: user_rbac_role user_rbac_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_rbac_role
    ADD CONSTRAINT user_rbac_role_pkey PRIMARY KEY (user_id, rbac_role_id);


--
-- Name: view_configuration view_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.view_configuration
    ADD CONSTRAINT view_configuration_pkey PRIMARY KEY (id);


--
-- Name: workflow_execution workflow_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_execution
    ADD CONSTRAINT workflow_execution_pkey PRIMARY KEY (workflow_id, transaction_id, run_id);


--
-- Name: IDX_account_holder_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_account_holder_deleted_at" ON public.account_holder USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_account_holder_id_5cb3a0c0" ON public.customer_account_holder USING btree (account_holder_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_provider_id_external_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_account_holder_provider_id_external_id_unique" ON public.account_holder USING btree (provider_id, external_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_deleted_at" ON public.api_key USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_redacted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_redacted" ON public.api_key USING btree (redacted) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_revoked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_revoked_at" ON public.api_key USING btree (revoked_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_token_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_api_key_token_unique" ON public.api_key USING btree (token);


--
-- Name: IDX_api_key_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_type" ON public.api_key USING btree (type);


--
-- Name: IDX_application_method_allocation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_application_method_allocation" ON public.promotion_application_method USING btree (allocation);


--
-- Name: IDX_application_method_target_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_application_method_target_type" ON public.promotion_application_method USING btree (target_type);


--
-- Name: IDX_application_method_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_application_method_type" ON public.promotion_application_method USING btree (type);


--
-- Name: IDX_auth_identity_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_auth_identity_deleted_at" ON public.auth_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_campaign_budget_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_campaign_budget_type" ON public.promotion_campaign_budget USING btree (type);


--
-- Name: IDX_capture_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_capture_deleted_at" ON public.capture USING btree (deleted_at);


--
-- Name: IDX_capture_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_capture_payment_id" ON public.capture USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_address_deleted_at" ON public.cart_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_billing_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_billing_address_id" ON public.cart USING btree (billing_address_id) WHERE ((deleted_at IS NULL) AND (billing_address_id IS NOT NULL));


--
-- Name: IDX_cart_credit_line_reference_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_credit_line_reference_reference_id" ON public.credit_line USING btree (reference, reference_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_currency_code" ON public.cart USING btree (currency_code);


--
-- Name: IDX_cart_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_customer_id" ON public.cart USING btree (customer_id) WHERE ((deleted_at IS NULL) AND (customer_id IS NOT NULL));


--
-- Name: IDX_cart_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_deleted_at" ON public.cart USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_id_-4a39f6c9" ON public.cart_payment_collection USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_id_-71069c16" ON public.order_cart USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_id_-a9d4a70b" ON public.cart_promotion USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_adjustment_deleted_at" ON public.cart_line_item_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_deleted_at" ON public.cart_line_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_tax_line_deleted_at" ON public.cart_line_item_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_region_id" ON public.cart USING btree (region_id) WHERE ((deleted_at IS NULL) AND (region_id IS NOT NULL));


--
-- Name: IDX_cart_sales_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_sales_channel_id" ON public.cart USING btree (sales_channel_id) WHERE ((deleted_at IS NULL) AND (sales_channel_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_address_id" ON public.cart USING btree (shipping_address_id) WHERE ((deleted_at IS NULL) AND (shipping_address_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_method_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_deleted_at" ON public.cart_shipping_method_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_deleted_at" ON public.cart_shipping_method USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_deleted_at" ON public.cart_shipping_method_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_category_handle_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_category_handle_unique" ON public.product_category USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_collection_handle_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_collection_handle_unique" ON public.product_collection USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_credit_line_cart_id" ON public.credit_line USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_credit_line_deleted_at" ON public.credit_line USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_address_customer_id" ON public.customer_address USING btree (customer_id);


--
-- Name: IDX_customer_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_address_deleted_at" ON public.customer_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_unique_customer_billing; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_billing" ON public.customer_address USING btree (customer_id) WHERE (is_default_billing = true);


--
-- Name: IDX_customer_address_unique_customer_shipping; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_shipping" ON public.customer_address USING btree (customer_id) WHERE (is_default_shipping = true);


--
-- Name: IDX_customer_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_deleted_at" ON public.customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_email_has_account_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_email_has_account_unique" ON public.customer USING btree (email, has_account) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_customer_customer_group_id" ON public.customer_group_customer USING btree (customer_group_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_customer_customer_id" ON public.customer_group_customer USING btree (customer_id);


--
-- Name: IDX_customer_group_customer_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_customer_deleted_at" ON public.customer_group_customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_deleted_at" ON public.customer_group USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_group_name_unique" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_id_5cb3a0c0" ON public.customer_account_holder USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_deleted_at_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-1e5992737" ON public.location_fulfillment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-31ea43a" ON public.return_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-4a39f6c9" ON public.cart_payment_collection USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-71069c16" ON public.order_cart USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-71518339" ON public.order_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-85069d44; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-85069d44" ON public.invite_rbac_role USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-a9d4a70b" ON public.cart_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-e88adb96" ON public.location_fulfillment_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-e8d2543e" ON public.order_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_17a262437" ON public.product_shipping_profile USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_17b4c4e35" ON public.product_variant_inventory_item USING btree (deleted_at);


--
-- Name: IDX_deleted_at_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_1c934dab0" ON public.region_payment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_20b454295" ON public.product_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_26d06f470" ON public.sales_channel_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_52b23597" ON public.product_variant_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_5cb3a0c0" ON public.customer_account_holder USING btree (deleted_at);


--
-- Name: IDX_deleted_at_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_64ff0c4c" ON public.user_rbac_role USING btree (deleted_at);


--
-- Name: IDX_deleted_at_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_ba32fa9c" ON public.shipping_option_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_f42b9949" ON public.order_payment_collection USING btree (deleted_at);


--
-- Name: IDX_fulfillment_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_address_deleted_at" ON public.fulfillment_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_deleted_at" ON public.fulfillment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_id_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_id_-31ea43a" ON public.return_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_id_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_id_-e8d2543e" ON public.order_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_deleted_at" ON public.fulfillment_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_item_fulfillment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_fulfillment_id" ON public.fulfillment_item USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_inventory_item_id" ON public.fulfillment_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_line_item_id" ON public.fulfillment_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_label_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_label_deleted_at" ON public.fulfillment_label USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_label_fulfillment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_label_fulfillment_id" ON public.fulfillment_label USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_location_id" ON public.fulfillment USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_provider_deleted_at" ON public.fulfillment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_id_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_provider_id_-1e5992737" ON public.location_fulfillment_provider USING btree (fulfillment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_set_deleted_at" ON public.fulfillment_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_set_id_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_set_id_-e88adb96" ON public.location_fulfillment_set USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_fulfillment_set_name_unique" ON public.fulfillment_set USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_shipping_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_shipping_option_id" ON public.fulfillment USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_city" ON public.geo_zone USING btree (city) WHERE ((deleted_at IS NULL) AND (city IS NOT NULL));


--
-- Name: IDX_geo_zone_country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_country_code" ON public.geo_zone USING btree (country_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_deleted_at" ON public.geo_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_geo_zone_province_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_province_code" ON public.geo_zone USING btree (province_code) WHERE ((deleted_at IS NULL) AND (province_code IS NOT NULL));


--
-- Name: IDX_geo_zone_service_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_service_zone_id" ON public.geo_zone USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_id_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (id);


--
-- Name: IDX_id_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-1e5992737" ON public.location_fulfillment_provider USING btree (id);


--
-- Name: IDX_id_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-31ea43a" ON public.return_fulfillment USING btree (id);


--
-- Name: IDX_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-4a39f6c9" ON public.cart_payment_collection USING btree (id);


--
-- Name: IDX_id_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-71069c16" ON public.order_cart USING btree (id);


--
-- Name: IDX_id_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-71518339" ON public.order_promotion USING btree (id);


--
-- Name: IDX_id_-85069d44; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-85069d44" ON public.invite_rbac_role USING btree (id);


--
-- Name: IDX_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-a9d4a70b" ON public.cart_promotion USING btree (id);


--
-- Name: IDX_id_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-e88adb96" ON public.location_fulfillment_set USING btree (id);


--
-- Name: IDX_id_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-e8d2543e" ON public.order_fulfillment USING btree (id);


--
-- Name: IDX_id_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_17a262437" ON public.product_shipping_profile USING btree (id);


--
-- Name: IDX_id_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (id);


--
-- Name: IDX_id_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_1c934dab0" ON public.region_payment_provider USING btree (id);


--
-- Name: IDX_id_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_20b454295" ON public.product_sales_channel USING btree (id);


--
-- Name: IDX_id_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_26d06f470" ON public.sales_channel_stock_location USING btree (id);


--
-- Name: IDX_id_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_52b23597" ON public.product_variant_price_set USING btree (id);


--
-- Name: IDX_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_5cb3a0c0" ON public.customer_account_holder USING btree (id);


--
-- Name: IDX_id_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_64ff0c4c" ON public.user_rbac_role USING btree (id);


--
-- Name: IDX_id_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_ba32fa9c" ON public.shipping_option_price_set USING btree (id);


--
-- Name: IDX_id_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_f42b9949" ON public.order_payment_collection USING btree (id);


--
-- Name: IDX_image_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_image_deleted_at" ON public.image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_image_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_image_product_id" ON public.image USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_item_deleted_at" ON public.inventory_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_item_id_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_item_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_inventory_item_sku" ON public.inventory_item USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_level_deleted_at" ON public.inventory_level USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_level_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_level_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_level_location_id" ON public.inventory_level USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_inventory_level_location_id_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_invite_deleted_at" ON public.invite USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_invite_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_invite_email_unique" ON public.invite USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_id_-85069d44; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_invite_id_-85069d44" ON public.invite_rbac_role USING btree (invite_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_invite_token" ON public.invite USING btree (token) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_adjustment_promotion_id" ON public.cart_line_item_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_line_item_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_product_id" ON public.cart_line_item USING btree (product_id) WHERE ((deleted_at IS NULL) AND (product_id IS NOT NULL));


--
-- Name: IDX_line_item_product_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_product_type_id" ON public.order_line_item USING btree (product_type_id) WHERE ((deleted_at IS NULL) AND (product_type_id IS NOT NULL));


--
-- Name: IDX_line_item_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_tax_line_tax_rate_id" ON public.cart_line_item_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_line_item_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_variant_id" ON public.cart_line_item USING btree (variant_id) WHERE ((deleted_at IS NULL) AND (variant_id IS NOT NULL));


--
-- Name: IDX_notification_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_deleted_at" ON public.notification USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_idempotency_key_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_notification_idempotency_key_unique" ON public.notification USING btree (idempotency_key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_provider_deleted_at" ON public.notification_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_provider_id" ON public.notification USING btree (provider_id);


--
-- Name: IDX_notification_receiver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_receiver_id" ON public.notification USING btree (receiver_id);


--
-- Name: IDX_option_product_id_title_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_option_product_id_title_unique" ON public.product_option USING btree (product_id, title) WHERE (deleted_at IS NULL);


--
-- Name: IDX_option_value_option_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_option_value_option_id_unique" ON public.product_option_value USING btree (option_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_address_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_address_customer_id" ON public.order_address USING btree (customer_id);


--
-- Name: IDX_order_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_address_deleted_at" ON public.order_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_billing_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_billing_address_id" ON public."order" USING btree (billing_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_claim_id" ON public.order_change_action USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_deleted_at" ON public.order_change_action USING btree (deleted_at);


--
-- Name: IDX_order_change_action_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_exchange_id" ON public.order_change_action USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_order_change_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_order_change_id" ON public.order_change_action USING btree (order_change_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_order_id" ON public.order_change_action USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_ordering" ON public.order_change_action USING btree (ordering) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_return_id" ON public.order_change_action USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_change_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_change_type" ON public.order_change USING btree (change_type);


--
-- Name: IDX_order_change_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_claim_id" ON public.order_change USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_deleted_at" ON public.order_change USING btree (deleted_at);


--
-- Name: IDX_order_change_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_exchange_id" ON public.order_change USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_order_id" ON public.order_change USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_order_id_version" ON public.order_change USING btree (order_id, version);


--
-- Name: IDX_order_change_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_return_id" ON public.order_change USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_status" ON public.order_change USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_version" ON public.order_change USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_deleted_at" ON public.order_claim USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_display_id" ON public.order_claim USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_claim_id" ON public.order_claim_item USING btree (claim_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_deleted_at" ON public.order_claim_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_claim_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_image_claim_item_id" ON public.order_claim_item_image USING btree (claim_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_image_deleted_at" ON public.order_claim_item_image USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_item_id" ON public.order_claim_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_order_id" ON public.order_claim USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_return_id" ON public.order_claim USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_credit_line_deleted_at" ON public.order_credit_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_credit_line_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_credit_line_order_id" ON public.order_credit_line USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_credit_line_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_credit_line_order_id_version" ON public.order_credit_line USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_currency_code" ON public."order" USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_custom_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_order_custom_display_id" ON public."order" USING btree (custom_display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_customer_id" ON public."order" USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_deleted_at" ON public."order" USING btree (deleted_at);


--
-- Name: IDX_order_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_display_id" ON public."order" USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_deleted_at" ON public.order_exchange USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_display_id" ON public.order_exchange USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_item_deleted_at" ON public.order_exchange_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_item_exchange_id" ON public.order_exchange_item USING btree (exchange_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_item_item_id" ON public.order_exchange_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_order_id" ON public.order_exchange USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_return_id" ON public.order_exchange USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_id_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_-71069c16" ON public.order_cart USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_-71518339" ON public.order_promotion USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_-e8d2543e" ON public.order_fulfillment USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_f42b9949" ON public.order_payment_collection USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_is_draft_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_is_draft_order" ON public."order" USING btree (is_draft_order) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_deleted_at" ON public.order_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_item_id" ON public.order_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_order_id" ON public.order_item USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_order_id_version" ON public.order_item USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_adjustment_item_id" ON public.order_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_product_id" ON public.order_line_item USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_tax_line_item_id" ON public.order_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_variant_id" ON public.order_line_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_region_id" ON public."order" USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_sales_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_sales_channel_id" ON public."order" USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_address_id" ON public."order" USING btree (shipping_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_claim_id" ON public.order_shipping USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_deleted_at" ON public.order_shipping USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_shipping_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_exchange_id" ON public.order_shipping USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_item_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_method_adjustment_shipping_method_id" ON public.order_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_adjustment_version_shipping_method; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_order_shipping_method_adjustment_version_shipping_method" ON public.order_shipping_method_adjustment USING btree (version, shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_shipping_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_method_shipping_option_id" ON public.order_shipping_method USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_method_tax_line_shipping_method_id" ON public.order_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_order_id" ON public.order_shipping USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_order_id_version" ON public.order_shipping USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_return_id" ON public.order_shipping USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_shipping_method_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_summary_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_summary_deleted_at" ON public.order_summary USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_summary_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_summary_order_id_version" ON public.order_summary USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_claim_id" ON public.order_transaction USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_currency_code" ON public.order_transaction USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_exchange_id" ON public.order_transaction USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_order_id" ON public.order_transaction USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_order_id_version" ON public.order_transaction USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_reference_id" ON public.order_transaction USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_return_id" ON public.order_transaction USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_payment_collection_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_collection_deleted_at" ON public.payment_collection USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_collection_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_collection_id_-4a39f6c9" ON public.cart_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_collection_id_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_collection_id_f42b9949" ON public.order_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_deleted_at" ON public.payment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_payment_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_payment_collection_id" ON public.payment USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_payment_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_payment_session_id" ON public.payment USING btree (payment_session_id);


--
-- Name: IDX_payment_payment_session_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_payment_payment_session_id_unique" ON public.payment USING btree (payment_session_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_provider_deleted_at" ON public.payment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_provider_id" ON public.payment USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_provider_id_1c934dab0" ON public.region_payment_provider USING btree (payment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_session_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_session_deleted_at" ON public.payment_session USING btree (deleted_at);


--
-- Name: IDX_payment_session_payment_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_session_payment_collection_id" ON public.payment_session USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_currency_code" ON public.price USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_deleted_at" ON public.price USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_deleted_at" ON public.price_list USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_id_status_starts_at_ends_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_id_status_starts_at_ends_at" ON public.price_list USING btree (id, status, starts_at, ends_at) WHERE ((deleted_at IS NULL) AND (status = 'active'::text));


--
-- Name: IDX_price_list_rule_attribute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_attribute" ON public.price_list_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_list_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_deleted_at" ON public.price_list_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_price_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_price_list_id" ON public.price_list_rule USING btree (price_list_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_value" ON public.price_list_rule USING gin (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_attribute_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_price_preference_attribute_value" ON public.price_preference USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_preference_deleted_at" ON public.price_preference USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_price_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_price_list_id" ON public.price USING btree (price_list_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_price_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_price_set_id" ON public.price USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_attribute" ON public.price_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_attribute_value" ON public.price_rule USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_attribute_value_price_id" ON public.price_rule USING btree (attribute, value, price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_deleted_at" ON public.price_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_rule_operator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_operator" ON public.price_rule USING btree (operator);


--
-- Name: IDX_price_rule_operator_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_operator_value" ON public.price_rule USING btree (operator, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_price_id" ON public.price_rule USING btree (price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id_attribute_operator_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_price_rule_price_id_attribute_operator_unique" ON public.price_rule USING btree (price_id, attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_set_deleted_at" ON public.price_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_set_id_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_set_id_52b23597" ON public.product_variant_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_id_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_set_id_ba32fa9c" ON public.shipping_option_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_parent_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_category_parent_category_id" ON public.product_category USING btree (parent_category_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_category_path" ON public.product_category USING btree (mpath) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_collection_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_collection_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_collection_id" ON public.product USING btree (collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_deleted_at" ON public.product USING btree (deleted_at);


--
-- Name: IDX_product_handle_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_handle_unique" ON public.product USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_id_17a262437" ON public.product_shipping_profile USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_id_20b454295" ON public.product_sales_channel USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_rank" ON public.image USING btree (rank) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_rank_product_id" ON public.image USING btree (rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_url" ON public.image USING btree (url) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url_rank_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_url_rank_product_id" ON public.image USING btree (url, rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_deleted_at" ON public.product_option USING btree (deleted_at);


--
-- Name: IDX_product_option_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_product_id" ON public.product_option USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_value_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_value_deleted_at" ON public.product_option_value USING btree (deleted_at);


--
-- Name: IDX_product_option_value_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_value_option_id" ON public.product_option_value USING btree (option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_status" ON public.product USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_tag_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_tag_deleted_at" ON public.product_tag USING btree (deleted_at);


--
-- Name: IDX_product_type_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_type_deleted_at" ON public.product_type USING btree (deleted_at);


--
-- Name: IDX_product_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_type_id" ON public.product USING btree (type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_barcode_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_barcode_unique" ON public.product_variant USING btree (barcode) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_deleted_at" ON public.product_variant USING btree (deleted_at);


--
-- Name: IDX_product_variant_ean_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_ean_unique" ON public.product_variant USING btree (ean) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_id_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_id_product_id" ON public.product_variant USING btree (id, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_id" ON public.product_variant USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_image_deleted_at" ON public.product_variant_product_image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_image_image_id" ON public.product_variant_product_image USING btree (image_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_image_variant_id" ON public.product_variant_product_image USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_sku_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_sku_unique" ON public.product_variant USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_upc_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_upc_unique" ON public.product_variant USING btree (upc) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_application_method_currency_code" ON public.promotion_application_method USING btree (currency_code) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_promotion_application_method_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_application_method_deleted_at" ON public.promotion_application_method USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_promotion_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_application_method_promotion_id_unique" ON public.promotion_application_method USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_campaign_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_campaign_id_unique" ON public.promotion_campaign_budget USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_budget_deleted_at" ON public.promotion_campaign_budget USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u" ON public.promotion_campaign_budget_usage USING btree (attribute_value, budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_budget_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_budget_id" ON public.promotion_campaign_budget_usage USING btree (budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_deleted_at" ON public.promotion_campaign_budget_usage USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_campaign_identifier_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_campaign_identifier_unique" ON public.promotion_campaign USING btree (campaign_identifier) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_deleted_at" ON public.promotion_campaign USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_id" ON public.promotion USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_deleted_at" ON public.promotion USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_id_-71518339" ON public.order_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_id_-a9d4a70b" ON public.cart_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_is_automatic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_is_automatic" ON public.promotion USING btree (is_automatic) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_attribute" ON public.promotion_rule USING btree (attribute);


--
-- Name: IDX_promotion_rule_attribute_operator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_attribute_operator" ON public.promotion_rule USING btree (attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_attribute_operator_id" ON public.promotion_rule USING btree (operator, attribute, id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_deleted_at" ON public.promotion_rule USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_operator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_operator" ON public.promotion_rule USING btree (operator);


--
-- Name: IDX_promotion_rule_value_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_deleted_at" ON public.promotion_rule_value USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_promotion_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_promotion_rule_id" ON public.promotion_rule_value USING btree (promotion_rule_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_rule_id_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_rule_id_value" ON public.promotion_rule_value USING btree (promotion_rule_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_value" ON public.promotion_rule_value USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_status" ON public.promotion USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_type" ON public.promotion USING btree (type);


--
-- Name: IDX_property_label_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_property_label_deleted_at" ON public.property_label USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_property_label_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_property_label_entity" ON public.property_label USING btree (entity) WHERE (deleted_at IS NULL);


--
-- Name: IDX_property_label_entity_property_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_property_label_entity_property_unique" ON public.property_label USING btree (entity, property) WHERE (deleted_at IS NULL);


--
-- Name: IDX_provider_identity_auth_identity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_provider_identity_auth_identity_id" ON public.provider_identity USING btree (auth_identity_id);


--
-- Name: IDX_provider_identity_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_provider_identity_deleted_at" ON public.provider_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_provider_identity_provider_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_provider_identity_provider_entity_id" ON public.provider_identity USING btree (entity_id, provider);


--
-- Name: IDX_publishable_key_id_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_publishable_key_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (publishable_key_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_rbac_role_id_-85069d44; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_rbac_role_id_-85069d44" ON public.invite_rbac_role USING btree (rbac_role_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_rbac_role_id_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_rbac_role_id_64ff0c4c" ON public.user_rbac_role USING btree (rbac_role_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_deleted_at" ON public.refund USING btree (deleted_at);


--
-- Name: IDX_refund_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_payment_id" ON public.refund USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_reason_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_reason_deleted_at" ON public.refund_reason USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_refund_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_refund_reason_id" ON public.refund USING btree (refund_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_country_deleted_at" ON public.region_country USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_country_region_id" ON public.region_country USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id_iso_2_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_region_country_region_id_iso_2_unique" ON public.region_country USING btree (region_id, iso_2);


--
-- Name: IDX_region_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_deleted_at" ON public.region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_region_id_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_id_1c934dab0" ON public.region_payment_provider USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_deleted_at" ON public.reservation_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_reservation_item_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_inventory_item_id" ON public.reservation_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_line_item_id" ON public.reservation_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_location_id" ON public.reservation_item USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_claim_id" ON public.return USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_display_id" ON public.return USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_exchange_id" ON public.return USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_id_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_id_-31ea43a" ON public.return_fulfillment USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_deleted_at" ON public.return_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_item_id" ON public.return_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_reason_id" ON public.return_item USING btree (reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_return_id" ON public.return_item USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_order_id" ON public.return USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_parent_return_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_reason_parent_return_reason_id" ON public.return_reason USING btree (parent_return_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_reason_value" ON public.return_reason USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_deleted_at" ON public.sales_channel USING btree (deleted_at);


--
-- Name: IDX_sales_channel_id_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_id_20b454295" ON public.product_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_id_26d06f470" ON public.sales_channel_stock_location USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_service_zone_deleted_at" ON public.service_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_service_zone_fulfillment_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_service_zone_fulfillment_set_id" ON public.service_zone USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_service_zone_name_unique" ON public.service_zone USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_method_adjustment_promotion_id" ON public.cart_shipping_method_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_shipping_method_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_method_option_id" ON public.cart_shipping_method USING btree (shipping_option_id) WHERE ((deleted_at IS NULL) AND (shipping_option_id IS NOT NULL));


--
-- Name: IDX_shipping_method_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_method_tax_line_tax_rate_id" ON public.cart_shipping_method_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_shipping_option_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_deleted_at" ON public.shipping_option USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_id_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_id_ba32fa9c" ON public.shipping_option_price_set USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_provider_id" ON public.shipping_option USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_rule_deleted_at" ON public.shipping_option_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_rule_shipping_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_rule_shipping_option_id" ON public.shipping_option_rule USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_service_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_service_zone_id" ON public.shipping_option USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_option_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_shipping_option_type_id" ON public.shipping_option USING btree (shipping_option_type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_shipping_profile_id" ON public.shipping_option USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_type_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_type_deleted_at" ON public.shipping_option_type USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_profile_deleted_at" ON public.shipping_profile USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_id_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_profile_id_17a262437" ON public.product_shipping_profile USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_profile_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_shipping_profile_name_unique" ON public.shipping_profile USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_single_default_region; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_single_default_region" ON public.tax_rate USING btree (tax_region_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- Name: IDX_stock_location_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_address_deleted_at" ON public.stock_location_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_address_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_stock_location_address_id_unique" ON public.stock_location USING btree (address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_deleted_at" ON public.stock_location USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_id_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_id_-1e5992737" ON public.location_fulfillment_provider USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_id_-e88adb96" ON public.location_fulfillment_set USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_id_26d06f470" ON public.sales_channel_stock_location USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_currency_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_currency_deleted_at" ON public.store_currency USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_currency_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_currency_store_id" ON public.store_currency USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_deleted_at" ON public.store USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_locale_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_locale_deleted_at" ON public.store_locale USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_locale_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_locale_store_id" ON public.store_locale USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tag_value_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tag_value_unique" ON public.product_tag USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_provider_deleted_at" ON public.tax_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_deleted_at" ON public.tax_rate USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_rule_deleted_at" ON public.tax_rate_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_rule_reference_id" ON public.tax_rate_rule USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_tax_rate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_rule_tax_rate_id" ON public.tax_rate_rule USING btree (tax_rate_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_unique_rate_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tax_rate_rule_unique_rate_reference" ON public.tax_rate_rule USING btree (tax_rate_id, reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_tax_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_tax_region_id" ON public.tax_rate USING btree (tax_region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_region_deleted_at" ON public.tax_region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_region_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_region_parent_id" ON public.tax_region USING btree (parent_id);


--
-- Name: IDX_tax_region_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_region_provider_id" ON public.tax_region USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_unique_country_nullable_province; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_nullable_province" ON public.tax_region USING btree (country_code) WHERE ((province_code IS NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_tax_region_unique_country_province; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_province" ON public.tax_region USING btree (country_code, province_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_type_value_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_type_value_unique" ON public.product_type USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_unique_promotion_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_unique_promotion_code" ON public.promotion USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_deleted_at" ON public."user" USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_user_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_user_email_unique" ON public."user" USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_id_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_id_64ff0c4c" ON public.user_rbac_role USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_preference_deleted_at" ON public.user_preference USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_preference_user_id" ON public.user_preference USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id_key_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_user_preference_user_id_key_unique" ON public.user_preference USING btree (user_id, key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_variant_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_variant_id_52b23597" ON public.product_variant_price_set USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_deleted_at" ON public.view_configuration USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_is_system_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_entity_is_system_default" ON public.view_configuration USING btree (entity, is_system_default) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_entity_user_id" ON public.view_configuration USING btree (entity, user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_user_id" ON public.view_configuration USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_deleted_at" ON public.workflow_execution USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_id" ON public.workflow_execution USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_retention_time_updated_at_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_retention_time_updated_at_state" ON public.workflow_execution USING btree (retention_time, updated_at, state) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL));


--
-- Name: IDX_workflow_execution_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_run_id" ON public.workflow_execution USING btree (run_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_state" ON public.workflow_execution USING btree (state) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_state_updated_at" ON public.workflow_execution USING btree (state, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_transaction_id" ON public.workflow_execution USING btree (transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_updated_at_retention_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_updated_at_retention_time" ON public.workflow_execution USING btree (updated_at, retention_time) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL) AND ((state)::text = ANY ((ARRAY['done'::character varying, 'failed'::character varying, 'reverted'::character varying])::text[])));


--
-- Name: IDX_workflow_execution_workflow_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_workflow_id" ON public.workflow_execution USING btree (workflow_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_workflow_id_transaction_id" ON public.workflow_execution USING btree (workflow_id, transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id_run_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_workflow_execution_workflow_id_transaction_id_run_id_unique" ON public.workflow_execution USING btree (workflow_id, transaction_id, run_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_script_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_script_name_unique ON public.script_migrations USING btree (script_name);


--
-- Name: tax_rate_rule FK_tax_rate_rule_tax_rate_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT "FK_tax_rate_rule_tax_rate_id" FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;


--
-- Name: tax_rate FK_tax_rate_tax_region_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_tax_rate_tax_region_id" FOREIGN KEY (tax_region_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_parent_id" FOREIGN KEY (parent_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_provider_id" FOREIGN KEY (provider_id) REFERENCES public.tax_provider(id) ON DELETE SET NULL;


--
-- Name: application_method_buy_rules application_method_buy_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_buy_rules application_method_buy_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: capture capture_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item cart_line_item_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method cart_shipping_method_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credit_line credit_line_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE;


--
-- Name: customer_address customer_address_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_delivery_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_delivery_address_id_foreign FOREIGN KEY (delivery_address_id) REFERENCES public.fulfillment_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment_item fulfillment_item_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment_label fulfillment_label_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment fulfillment_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: geo_zone geo_zone_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image image_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_level inventory_level_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification notification_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.notification_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order order_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_change_action order_change_action_order_change_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_order_change_id_foreign FOREIGN KEY (order_change_id) REFERENCES public.order_change(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change order_change_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_credit_line order_credit_line_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_adjustment order_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_tax_line order_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item order_line_item_totals_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_totals_id_foreign FOREIGN KEY (totals_id) REFERENCES public.order_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order order_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping order_shipping_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_summary order_summary_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_transaction order_transaction_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_col_aa276_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_col_aa276_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_pro_2d555_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_pro_2d555_foreign FOREIGN KEY (payment_provider_id) REFERENCES public.payment_provider(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment payment_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_session payment_session_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_list_rule price_list_rule_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_set_id_foreign FOREIGN KEY (price_set_id) REFERENCES public.price_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_rule price_rule_price_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_price_id_foreign FOREIGN KEY (price_id) REFERENCES public.price(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category product_category_parent_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_parent_category_id_foreign FOREIGN KEY (parent_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_category_id_foreign FOREIGN KEY (product_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_collection_id_foreign FOREIGN KEY (collection_id) REFERENCES public.product_collection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_option product_option_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_option_value product_option_value_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_option_id_foreign FOREIGN KEY (option_id) REFERENCES public.product_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_tag_id_foreign FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.product_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_variant_option product_variant_option_option_value_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_option_value_id_foreign FOREIGN KEY (option_value_id) REFERENCES public.product_option_value(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_option product_variant_option_variant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_variant_id_foreign FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant product_variant_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_product_image product_variant_product_image_image_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_image_id_foreign FOREIGN KEY (image_id) REFERENCES public.image(id) ON DELETE CASCADE;


--
-- Name: promotion_application_method promotion_application_method_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget promotion_campaign_budget_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.promotion_campaign_budget(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion promotion_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_rule_value promotion_rule_value_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: provider_identity provider_identity_auth_identity_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_auth_identity_id_foreign FOREIGN KEY (auth_identity_id) REFERENCES public.auth_identity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refund refund_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: region_country region_country_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reservation_item reservation_item_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: return_reason return_reason_parent_return_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_parent_return_reason_id_foreign FOREIGN KEY (parent_return_reason_id) REFERENCES public.return_reason(id);


--
-- Name: service_zone service_zone_fulfillment_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_fulfillment_set_id_foreign FOREIGN KEY (fulfillment_set_id) REFERENCES public.fulfillment_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: shipping_option_rule shipping_option_rule_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_option_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_option_type_id_foreign FOREIGN KEY (shipping_option_type_id) REFERENCES public.shipping_option_type(id) ON UPDATE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_profile_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_profile_id_foreign FOREIGN KEY (shipping_profile_id) REFERENCES public.shipping_profile(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: stock_location stock_location_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_address_id_foreign FOREIGN KEY (address_id) REFERENCES public.stock_location_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_currency store_currency_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_locale store_locale_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict MLshGL83OgbxB71QPdgtb442iuLN1F3zW2YPs80alfxrPKkRKsMdi4z6KxwEeLK

