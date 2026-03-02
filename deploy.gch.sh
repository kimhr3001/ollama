#!/usr/bin/env bash

set -euo pipefail

# 기본 설정
# 기본 프로젝트 ID: illai-488306 (gcp-account.json 의 project_id)
PROJECT_ID="${PROJECT_ID:-illai-488306}"
REGION="${REGION:-asia-northeast3}" # 서울
SERVICE_NAME="${SERVICE_NAME:-ollama-gpu}"
IMAGE="${IMAGE:-gcr.io/${PROJECT_ID}/ollama:latest}"

echo "프로젝트 ID: ${PROJECT_ID}"
echo "리전: ${REGION}"
echo "서비스: ${SERVICE_NAME}"
echo "이미지: ${IMAGE}"

# Cloud Run API 활성화 (없으면)
gcloud services enable run.googleapis.com compute.googleapis.com artifactregistry.googleapis.com --project "${PROJECT_ID}"

# Docker 이미지 빌드 및 푸시
echo "Docker 이미지 빌드 및 푸시..."
# 현재 리포지토리에서는 Dockerfile 이름이 'dockerfile' 이므로 --dockerfile 옵션을 명시
gcloud builds submit . \
  --tag "${IMAGE}" \
  --project "${PROJECT_ID}"

echo "Cloud Run (fully managed) 에 배포..."

gcloud run deploy "${SERVICE_NAME}" \
  --project="${PROJECT_ID}" \
  --region="${REGION}" \
  --platform=managed \
  --image="${IMAGE}" \
  --memory=32Gi \
  --cpu=4 \
  --gpu=type=nvidia-l4,count=1 \
  --min-instances=0 \
  --max-instances=1 \
  --port=8080 \
  --allow-unauthenticated \
  --execution-environment=gen2 \
  --no-cpu-boost \
  --no-use-http2

echo "배포가 완료되었습니다."
