docker build --tag flutter_frame .
mkdir -p release
docker run --volume $PWD/release:/host flutter_frame cp -R /app/build/flutter_assets /host/.
