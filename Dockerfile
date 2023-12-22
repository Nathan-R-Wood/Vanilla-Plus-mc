FROM docker.io/openjdk as builder 
RUN echo Running this build file accepts the minecraft EULA
RUN mkdir -p /Minecraft/server
WORKDIR /Minecraft
ADD https://meta.fabricmc.net/v2/versions/loader/1.20.4/0.15.3/0.11.2/server/jar /Minecraft/server/mc.jar
ADD https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar /Minecraft/server
RUN echo "eula=true" > server/eula.txt
WORKDIR /Minecraft/server
COPY . /Minecraft/server
RUN java -jar packwiz-installer-bootstrap.jar -g -s server file:///Minecraft/server/pack.toml
RUN rm -r mods/*.toml
RUN rm index.toml pack.toml packwiz-installer-bootstrap.jar packwiz-installer.jar packwiz.json
RUN mkdir world

FROM docker.io/alpine
RUN apk add openjdk17-jre-headless --no-cache
COPY --from=builder /Minecraft /Minecraft
WORKDIR /Minecraft/server
ENV RAM 4G
CMD ["sh", "-c", "java -Xmx$RAM -jar mc.jar nogui"]
