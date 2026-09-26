#!/usr/bin/env bash
# Simula o ASG com Docker e roda o userdata.sh de verdade em duas
# "instâncias" Amazon Linux 2023, com um IMDSv2 falso e um nginx no papel do ALB.
# Uso: ./simular.sh        sobe, testa e deixa a página em http://localhost:18390
#      ./simular.sh down   remove containers e rede
set -euo pipefail
cd "$(dirname "$0")"
ROOT=$(cd ../.. && pwd)
P=fiap-iac-cp2
PORT=${PORT:-18390}
NET=$P-vpc

down() {
  docker rm -f "$P-alb" "$P-web-1a" "$P-web-1c" "$P-imds" >/dev/null 2>&1 || true
  docker network rm "$NET" >/dev/null 2>&1 || true
}
if [ "${1:-}" = "down" ]; then down; echo "removido"; exit 0; fi
down

echo "1/4 rede e IMDS falso (169.254.169.254)"
docker network create --subnet 169.254.169.0/24 "$NET" >/dev/null
docker run -d --name "$P-imds" --network "$NET" --ip 169.254.169.254 \
  -v "$PWD/imds_mock.py:/imds_mock.py:ro" python:3.12-alpine python /imds_mock.py >/dev/null

echo "2/4 duas instâncias Amazon Linux 2023 rodando o userdata.sh"
for i in 1a:10 1c:20; do
  az=${i%%:*}; ip=${i##*:}
  docker run -d --name "$P-web-$az" --network "$NET" --ip "169.254.169.$ip" \
    -v "$ROOT/terraform/modules/compute/scripts/userdata.sh:/userdata.sh:ro" \
    amazonlinux:2023 sleep infinity >/dev/null
done
for az in 1a 1c; do docker exec "$P-web-$az" bash /userdata.sh 2>&1 | tail -1 & done
wait

echo "3/4 nginx no papel do ALB em http://localhost:$PORT"
docker run -d --name "$P-alb" --network "$NET" --ip 169.254.169.5 -p "127.0.0.1:$PORT:80" \
  -v "$PWD/nginx.conf:/etc/nginx/nginx.conf:ro" nginx:alpine >/dev/null
sleep 2

echo "4/4 testando"
fail=0
check() { if eval "$2"; then echo "  ok    $1"; else echo "  FALHA $1"; fail=1; fi; }
check "página responde pelo ALB" \
  "curl -fs http://localhost:$PORT/ | grep -q 'Esta página saiu da instância <em>i-'"
ids=$(for n in 1 2 3 4 5 6; do curl -fs "http://localhost:$PORT/instance.json"; echo; done | grep -o '"instance_id":"[^"]*"' | sort -u | wc -l)
check "ALB alterna entre as duas instâncias ($ids distintas em 6 requisições)" "[ $ids -eq 2 ]"
check "instâncias em AZs diferentes" \
  "[ \$(for n in 1 2 3 4; do curl -fs http://localhost:$PORT/instance.json; echo; done | grep -o 'us-east-1[ac]' | sort -u | wc -l) -eq 2 ]"
check "IMDS sem token recusado (IMDSv2)" \
  "[ \$(docker exec $P-web-1a curl -s -o /dev/null -w '%{http_code}' http://169.254.169.254/latest/meta-data/instance-id) = 401 ]"
exit $fail
