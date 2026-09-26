#!/bin/bash
# Inicialização das instâncias do Auto Scaling Group: Apache + página que
# mostra qual instância (e em qual AZ) respondeu a requisição do ALB.
set -u

echo "Instalando o Apache"
if command -v dnf >/dev/null 2>&1; then PKG=dnf; else PKG=yum; fi
$PKG install -y httpd

echo "Lendo os metadados da instância (IMDSv2)"
IMDS=http://169.254.169.254/latest
TOKEN=$(curl -s -m 3 -X PUT "$IMDS/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
md() { curl -s -m 3 -H "X-aws-ec2-metadata-token: $TOKEN" "$IMDS/meta-data/$1" || echo "?"; }
INSTANCE_ID=$(md instance-id)
AZ=$(md placement/availability-zone)
PRIVATE_IP=$(md local-ipv4)
INSTANCE_TYPE=$(md instance-type)
BOOTED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

WEB=/var/www/html
mkdir -p "$WEB"

# instance.json: lido pela página a cada 2 s. Cada leitura passa pelo ALB,
# então a resposta pode vir de outra instância.
cat > "$WEB/instance.json" <<JSON
{"instance_id":"$INSTANCE_ID","az":"$AZ","private_ip":"$PRIVATE_IP","instance_type":"$INSTANCE_TYPE","booted_at":"$BOOTED_AT"}
JSON

cat > "$WEB/index.html" <<'HTML'
<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>fiap-iac-cp2 · __INSTANCE_ID__</title>
<style>
  :root {
    --bg: #F4F3EF; --card: #FFFFFF; --ink: #1C1C1A; --muted: #6B6A64; --line: #E2E0D8;
    --accent: #D97706; --accent-soft: #FEF3E2; --navy: #232F3E; --ok: #1F7A4D;
    --mono: ui-monospace, "SFMono-Regular", "Cascadia Mono", "Ubuntu Mono", Menlo, Consolas, monospace;
    --sans: system-ui, -apple-system, "Segoe UI", Ubuntu, Roboto, "Helvetica Neue", Arial, sans-serif;
  }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--bg); color: var(--ink); font: 16px/1.5 var(--sans); }
  .wrap { max-width: 980px; margin: 0 auto; padding: 32px 20px 48px; }
  .top { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap;
         font: 13px/1 var(--mono); color: var(--muted); }
  .tag { display: inline-flex; align-items: center; gap: 8px; padding: 6px 10px; border-radius: 999px; background: var(--navy); color: #fff; }
  .tag i { width: 8px; height: 8px; border-radius: 50%; background: var(--accent); }
  h1 { font-size: clamp(32px, 5.6vw, 52px); line-height: 1.08; letter-spacing: -.02em; margin: 44px 0 10px; }
  h1 em { display: block; font-style: normal; color: var(--accent); font-family: var(--mono); font-size: .72em; letter-spacing: -.01em; overflow-wrap: anywhere; margin-top: 6px; }
  .lead { color: var(--muted); font-size: 18px; margin: 0 0 34px; max-width: 660px; }
  .grid { display: grid; grid-template-columns: 1fr 1.2fr; gap: 20px; }
  .grid > * { min-width: 0; }
  @media (max-width: 780px) { .grid { grid-template-columns: 1fr; } }
  .card { background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 22px 24px; }
  .card h2 { margin: 0 0 16px; font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); }
  dl { margin: 0; display: grid; grid-template-columns: auto 1fr; gap: 10px 18px; }
  dt { color: var(--muted); font-size: 14px; }
  dd { margin: 0; font: 14px/1.45 var(--mono); overflow-wrap: anywhere; }
  .azs { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 18px; }
  .az { border: 1.5px dashed var(--line); border-radius: 8px; padding: 12px 14px; transition: border-color .3s, background .3s; }
  .az b { display: block; font: 600 14px var(--mono); }
  .az span { display: block; font-size: 13px; color: var(--muted); }
  .az.hit { border-style: solid; border-color: var(--accent); background: var(--accent-soft); }
  .az .n { font: 700 26px/1.2 var(--sans); color: var(--ink); margin-top: 6px; }
  ol { list-style: none; margin: 0; padding: 0; font: 13px/1.5 var(--mono); }
  ol li { display: grid; grid-template-columns: 64px 1fr auto; gap: 10px; padding: 7px 0; border-top: 1px solid var(--line); }
  ol li:first-child { border-top: 0; }
  ol li .t { color: var(--muted); }
  ol li .z { color: var(--accent); }
  .empty { color: var(--muted); font-size: 14px; }
  .note { margin: 14px 0 0; font-size: 14px; color: var(--muted); }
  footer { margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line); display: flex;
           justify-content: space-between; flex-wrap: wrap; gap: 8px; font-size: 13px; color: var(--muted); }
  footer a { color: inherit; }
</style>
</head>
<body>
<div class="wrap">
  <div class="top">
    <span>FIAP · Infraestrutura como Código · Checkpoint 2</span>
    <span class="tag"><i></i>AWS · us-east-1</span>
  </div>

  <h1>Esta página saiu da instância <em>__INSTANCE_ID__</em></h1>
  <p class="lead">Ela roda num Auto Scaling Group espalhado por duas zonas de disponibilidade, atrás de um
    Application Load Balancer. O quadro de respostas pergunta ao ALB, a cada 2 segundos, quem está atendendo.</p>

  <div class="grid">
    <section class="card">
      <h2>Quem montou esta página</h2>
      <dl>
        <dt>Instância</dt><dd>__INSTANCE_ID__</dd>
        <dt>Zona</dt><dd>__AZ__</dd>
        <dt>IP privado</dt><dd>__PRIVATE_IP__</dd>
        <dt>Tipo</dt><dd>__INSTANCE_TYPE__</dd>
        <dt>Subiu em</dt><dd>__BOOTED_AT__</dd>
        <dt>Rede</dt><dd>sub-rede privada · saída pelo NAT</dd>
      </dl>
    </section>

    <section class="card">
      <h2>Respostas do load balancer</h2>
      <div class="azs">
        <div class="az" id="az-us-east-1a"><b>us-east-1a</b><span>sn-priv-az1a</span><div class="n" id="n-us-east-1a">0</div></div>
        <div class="az" id="az-us-east-1c"><b>us-east-1c</b><span>sn-priv-az1c</span><div class="n" id="n-us-east-1c">0</div></div>
      </div>
      <ol id="log"><li class="empty">aguardando a primeira resposta…</li></ol>
      <p class="note">Cada linha é um <code>GET /instance.json</code> que passou pelo ALB. Com duas ou mais
        instâncias saudáveis, as respostas se alternam entre elas.</p>
    </section>
  </div>

  <footer>
    <span>Provisionado com Terraform · fiap-iac-cp2</span>
    <span>William Coelho · <a href="https://github.com/willtechdev">@willtechdev</a></span>
  </footer>
</div>
<script>
  (function () {
    var log = document.getElementById("log");
    var counts = {};
    var first = true;
    function add(r) {
      if (first) { log.innerHTML = ""; first = false; }
      counts[r.az] = (counts[r.az] || 0) + 1;
      var n = document.getElementById("n-" + r.az);
      if (n) n.textContent = counts[r.az];
      ["us-east-1a", "us-east-1c"].forEach(function (z) {
        var el = document.getElementById("az-" + z);
        if (el) el.className = "az" + (z === r.az ? " hit" : "");
      });
      var li = document.createElement("li");
      var t = document.createElement("span"); t.className = "t"; t.textContent = new Date().toLocaleTimeString("pt-BR");
      var i = document.createElement("span"); i.textContent = r.instance_id;
      var z = document.createElement("span"); z.className = "z"; z.textContent = r.az;
      li.appendChild(t); li.appendChild(i); li.appendChild(z);
      log.insertBefore(li, log.firstChild);
      while (log.children.length > 6) log.removeChild(log.lastChild);
    }
    function tick() {
      fetch("instance.json?t=" + Date.now(), { cache: "no-store" })
        .then(function (res) { return res.json(); })
        .then(add)
        .catch(function () {});
    }
    tick();
    setInterval(tick, 2000);
  })();
</script>
</body>
</html>
HTML

sed -i \
  -e "s|__INSTANCE_ID__|$INSTANCE_ID|g" \
  -e "s|__AZ__|$AZ|g" \
  -e "s|__PRIVATE_IP__|$PRIVATE_IP|g" \
  -e "s|__INSTANCE_TYPE__|$INSTANCE_TYPE|g" \
  -e "s|__BOOTED_AT__|$BOOTED_AT|g" \
  "$WEB/index.html"

echo "Iniciando o Apache"
systemctl enable --now httpd 2>/dev/null || httpd -k start
echo "cp2: $INSTANCE_ID ($AZ) pronta"
