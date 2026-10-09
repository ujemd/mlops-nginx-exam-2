.PHONY: start-project stop-project test

start-project:
	docker compose -p nginx_exam up -d --build
	@echo "Waiting for the stack to be ready..."
	@for i in $$(seq 1 60); do \
		code=$$(curl -s -o /dev/null -w '%{http_code}' -X POST https://localhost/predict -H 'Content-Type: application/json' -d '{"sentence":"warmup"}' --user admin:admin --cacert deployments/nginx/certs/nginx.crt); \
		[ "$$code" = "200" ] && break; sleep 2; \
	done
	@for i in $$(seq 1 60); do curl -sf http://localhost:3000/api/health > /dev/null && break; sleep 2; done
	@for i in $$(seq 1 60); do curl -sf http://localhost:9090/api/v1/status/runtimeinfo > /dev/null && break; sleep 2; done
	@echo "Stack is ready."

stop-project:
	docker compose -p nginx_exam down

run-project:
	# run project
	@echo "Grafana UI: http://localhost:3000"

test:
	@bash tests/run_tests.sh

test-api:
	curl -X POST "https://localhost/predict" \
     -H "Content-Type: application/json" \
     -d '{"sentence": "Oh yeah, that was soooo cool!"}' \
	 --user admin:admin \
     --cacert ./deployments/nginx/certs/nginx.crt;
