FROM public.ecr.aws/nginx/nginx:alpine

COPY ./2048/ /usr/share/nginx/html/

#checkov:skip=CKV_DOCKER_2:HealthCheck handled in AWS
#checkov:skip=CKV_DOCKER_3:TODO Ensure a user is created
