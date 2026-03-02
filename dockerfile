FROM ollama/ollama:latest

ARG MODEL_FILE_NAME
ARG MODEL_NAME

ENV MODEL_FILE_NAME=${MODEL_FILE_NAME:-a.Modelfile}
ENV MODEL_NAME=${MODEL_NAME:-qwen3}

ARG MODEL_NAME_TAG=latest
ENV MODEL_NAME_TAG=${MODEL_NAME_TAG}

ENV OLLAMA_HOST=0.0.0.0:8080

ENV OLLAMA_DEBUG=false

# 5 minutes
ENV OLLAMA_KEEP_ALIVE=300
ENV MODEL=${MODEL_NAME}:${MODEL_NAME_TAG}

COPY . .

EXPOSE 8080

# 컨테이너 시작 시 모델을 생성/다운로드 한 뒤 serve
CMD ["sh", "-lc", "ollama serve & sleep 10 && ollama create ${MODEL} -f ${MODEL_FILE_NAME} || ollama pull ${MODEL} && wait"]