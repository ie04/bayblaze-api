# Bayblaze Label Printer Agent

Small Windows 11 LAN service that receives Bayblaze order label jobs, renders a black-and-white 4x6 label, and prints it through the Windows printer driver.

## Setup

1. Install Node.js 20 or newer on the Windows PC.
2. From this folder, run `npm install`.
3. Copy `.env.example` to `.env` and set:
   - `LABEL_AGENT_TOKEN` to a long shared secret.
   - `LABEL_PRINTER_NAME` to the exact Windows printer name.
4. List printer names with:

```powershell
npm run list:printers
```

5. Start the agent:

```powershell
npm start
```

By default it listens on `http://0.0.0.0:4786`.

## Medusa Environment

Set these on the Medusa backend:

```bash
LABEL_PRINTER_AGENT_URL=http://WINDOWS_PC_LAN_IP:4786
LABEL_PRINTER_AGENT_TOKEN=the-same-token
LABEL_PRINTER_PUBLIC_ORDER_BASE_URL=https://bayblaze.net/orders
```

If Medusa runs outside your local network, it cannot reach a private Windows LAN IP directly. In that case, expose the agent through a VPN or secure tunnel and use that URL for `LABEL_PRINTER_AGENT_URL`.
