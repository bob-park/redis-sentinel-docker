# `redis-sentinel`

이 repository 는 redis sentinel 을 간단하게 설정할 수 있도록 docker container 로 만든 것이다.

## package

| key          | 설명                   | version | 비고                       |
|--------------|------------------------|:--------|----------------------------|
| redis        | base image (`redis`)   | latest  | `redis-sentinel` 포함      |
| gettext-base | env 사용으로 인한 설치 |         | `envsubst` binary 만 복사 |

## env

| key         | 설명                                  | default value | required | 비고                                 |
|-------------|---------------------------------------|:-------------:|:--------:|--------------------------------------|
| HOST_IP     | sentinel announce ip                  |               |    ✔︎    | 다른 sentinel / redis 가 접근하는 ip |
| PORT        | sentinel port (announce port 와 동일) |     26379     |          |                                      |
| MASTER_NAME | monitoring 할 master 이름             | cache-master  |          |                                      |
| MASTER_IP   | master redis ip                       |               |    ✔︎    |                                      |
| MASTER_PORT | master redis port                     |     6379      |          |                                      |
| QUORUM      | failover 판정에 필요한 sentinel 수    |       2       |          |                                      |

* 아래 값은 고정이며, 변경하려면 `sentinel.conf.template` 을 수정해야 한다.
    * `down-after-milliseconds`: 5000
    * `failover-timeout`: 60000
    * `parallel-syncs`: 1

## Example (docker compose)

* `HOST_IP` 는 다른 sentinel / redis 에서 접근 가능한 ip 여야 한다.
    * `network_mode: host` 를 권장
    * bridge network 사용 시, `PORT` 와 동일한 port 로 publish 해야 한다.
* `/etc/redis/sentinel.conf` 는 최초 실행 시에만 생성된다.
    * sentinel 이 runtime 에 conf 를 갱신하므로, volume 으로 유지하는 것을 권장
    * env 를 변경했다면 volume 의 `sentinel.conf` 를 삭제해야 반영된다.

```yaml
name: cache-ha

services:
  sentinel:
    image: ghcr.io/bob-park/redis-sentinel
    network_mode: host
    environment:
      - HOST_IP=192.168.0.11
      - MASTER_NAME=cache-master
      - MASTER_IP=192.168.0.10
      - MASTER_PORT=6379
      - QUORUM=2
    volumes:
      - sentinel-data:/etc/redis

volumes:
  sentinel-data:
```

## build

```bash
docker buildx bake -f docker-compose.yml --push --provenance false
```
