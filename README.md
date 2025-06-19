# ss-wg-tunnel

**WireGuard to Shadowsocks Tunnel — ready-to-use Docker setup for a site-to-site VPN**

This repository contains a minimal, practical `docker-compose` configuration to run a WireGuard server behind a Shadowsocks tunnel.  
It’s tested for stable site-to-site connections from a secured perimeter (country) through an overseas VPS.  
This setup includes only the **inside-country part**. To use it, you also need another server abroad running Shadowsocks — this repo does not provide that, but you can find it in the official [Shadowsocks project](https://github.com/shadowsocks/shadowsocks-libev).

👉 [Read the full blog post](https://zloom.org/blogs/wireguard-to-shadowsocks-ready-docker-setup)

---

## Project Structure

- `docker-compose.yml` — main entry point
- `wireguard/` — WireGuard Docker build context
- `tunnel/` — Shadowsocks tunnel Docker build context
- `config/` — stores generated WireGuard configs

---

## Quick Start

1. **Clone the repository**

   ```
   git clone https://github.com/zloom/ss-wg-tunnel.git
   cd ss-wg-tunnel
   ```

2. **Adjust environment variables**

   - `SERVER_HOST` — your public IP for WireGuard  
   - `PEER_COUNT` — number of WireGuard clients to generate  
   - `SS_SERVER` — Shadowsocks server IP  
   - `SS_PASSWORD` — Shadowsocks password  
   - `SS_PORT` — Shadowsocks port  

   Edit these directly in `docker-compose.yml`.

3. **Run**

   ```
   docker compose up --build
   ```

4. **Retrieve WireGuard configs**

   Generated configs will appear in the `./config` folder.

---

## Notes

- Works best on **Docker Desktop** because of stricter network isolation.
- Designed for personal site-to-site tunnels with Shadowsocks as stealth transport.
- All parts except kernel WireGuard are written in Golang — I plan to merge them into a single binary later.
- For usage details and the full context, see the [blog post](https://zloom.org/blogs/wireguard-to-shadowsocks-ready-docker-setup).
