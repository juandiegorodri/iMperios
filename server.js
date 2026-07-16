#!/usr/bin/env node
/* Relé WebSocket para el multijugador de iMperios (escritorio / desarrollo).
   Uso: `node server.js` en el computador del ANFITRIÓN. Acepta exactamente 2
   jugadores y reenvía cada mensaje de uno al otro (tubería tonta, sin lógica).
   En la app iOS este mismo papel lo cumple RelayServer.swift dentro del
   dispositivo anfitrión. Protocolo del juego: ver iOS.md.                    */
'use strict';
const net = require('net');
const crypto = require('crypto');

const PORT = 8765;
const MAGIC = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
let peers = [];   // máximo 2 sockets emparejados

function acceptKey(key){
  return crypto.createHash('sha1').update(key + MAGIC).digest('base64');
}

// Codifica un frame de texto servidor→cliente (sin máscara).
function encodeText(str){
  const payload = Buffer.from(str, 'utf8');
  const len = payload.length;
  let header;
  if(len < 126){ header = Buffer.from([0x81, len]); }
  else if(len < 65536){ header = Buffer.alloc(4); header[0]=0x81; header[1]=126; header.writeUInt16BE(len,2); }
  else { header = Buffer.alloc(10); header[0]=0x81; header[1]=127; header.writeBigUInt64BE(BigInt(len),2); }
  return Buffer.concat([header, payload]);
}

const server = net.createServer(sock => {
  let buf = Buffer.alloc(0);
  let upgraded = false;

  sock.on('data', chunk => {
    buf = Buffer.concat([buf, chunk]);

    // 1) Handshake HTTP → WebSocket
    if(!upgraded){
      const idx = buf.indexOf('\r\n\r\n');
      if(idx === -1) return;
      const head = buf.slice(0, idx).toString();
      buf = buf.slice(idx + 4);
      const m = head.match(/Sec-WebSocket-Key: *(.+)\r\n/i);
      if(!m){ sock.destroy(); return; }
      if(peers.length >= 2){ sock.end('HTTP/1.1 503 Full\r\n\r\n'); return; }
      sock.write('HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\n' +
        'Connection: Upgrade\r\nSec-WebSocket-Accept: ' + acceptKey(m[1].trim()) + '\r\n\r\n');
      upgraded = true;
      peers.push(sock);
      console.log(`[relé] jugador conectado (${peers.length}/2)`);
    }

    // 2) Parsear frames del cliente (vienen enmascarados) y reenviar al otro par
    while(buf.length >= 2){
      const fin = (buf[0] & 0x80) !== 0;
      const op = buf[0] & 0x0f;
      const masked = (buf[1] & 0x80) !== 0;
      let len = buf[1] & 0x7f, off = 2;
      if(len === 126){ if(buf.length < 4) return; len = buf.readUInt16BE(2); off = 4; }
      else if(len === 127){ if(buf.length < 10) return; len = Number(buf.readBigUInt64BE(2)); off = 10; }
      const maskOff = off, dataOff = masked ? off + 4 : off;
      if(buf.length < dataOff + len) return;   // frame incompleto, esperar más datos
      let payload = buf.slice(dataOff, dataOff + len);
      if(masked){
        const mask = buf.slice(maskOff, maskOff + 4);
        payload = Buffer.from(payload.map((b, i) => b ^ mask[i % 4]));
      }
      buf = buf.slice(dataOff + len);
      if(!fin){ console.warn('[relé] frame fragmentado ignorado'); continue; }
      if(op === 0x8){ sock.end(); return; }                    // close
      if(op === 0x9){ sock.write(Buffer.from([0x8a, 0x00])); continue; }   // ping → pong
      if(op !== 0x1) continue;                                  // solo texto
      const other = peers.find(p => p !== sock);
      if(other) other.write(encodeText(payload.toString('utf8')));
    }
  });

  const drop = () => {
    if(peers.includes(sock)){
      peers = peers.filter(p => p !== sock);
      console.log(`[relé] jugador desconectado (${peers.length}/2)`);
      // avisa al que queda cerrando su conexión (el juego muestra "conexión perdida")
      for(const p of peers) p.end();
      peers = [];
    }
  };
  sock.on('close', drop);
  sock.on('error', drop);
});

server.listen(PORT, () => {
  console.log(`[relé] iMperios escuchando en el puerto ${PORT}`);
  console.log('[relé] Anfitrión: pulsa "Crear partida". El otro jugador se une con la IP de esta máquina.');
});
