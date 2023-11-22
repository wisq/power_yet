# ex:sw=4

# ---- Build Stage ----
FROM elixir:1.15-alpine AS builder

# Set environment variables for building the application
ARG mix_env
ENV MIX_ENV=${mix_env} \
    LANG=C.UTF-8 \
    ENDPOINT_MODE=docker

# Install build dependencies
RUN apk add --update-cache build-base git npm \
    && rm -rf /var/cache/apk/*

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the application build directory
RUN mkdir /app
WORKDIR /app

# Copy dependency configuration
COPY mix.exs .
COPY mix.lock .
COPY config/config.exs ./config/
COPY config/${mix_env}.deps.exs ./config/
RUN touch config/${mix_env}.exs

# Fetch JS dependencies
COPY assets/package.json ./assets/
COPY assets/package-lock.json ./assets/
RUN cd assets && npm install

# Fetch and build the application dependencies
RUN mix deps.get --only ${mix_env}
RUN mix deps.compile

# Install esbuild early on to avoid fetching it every deploy
RUN mix esbuild.install

# Copy over remaining build files
COPY config/${mix_env}.exs ./config/
COPY lib ./lib
COPY priv ./priv
COPY assets ./assets

# Compile and release
RUN mix compile
RUN mix assets.deploy
COPY config/runtime.exs ./config/
RUN mix release


# ---- Runtime Stage ----
FROM erlang:26-alpine AS release

# Set environment variables
ARG mix_env
ENV MIX_ENV=${mix_env} \
    LANG=C.UTF-8 \
    ENDPOINT_MODE=docker

# Create the application runtime directory
RUN mkdir /app
WORKDIR /app

# Copy release
COPY --from=builder /app/_build/${mix_env}/rel/power_yet/ /app/

# Set entrypoint
ENTRYPOINT ["/app/bin/power_yet"]
