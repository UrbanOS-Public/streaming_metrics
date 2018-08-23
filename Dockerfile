FROM elixir:1.6.5
ENV MIX_ENV test
COPY . /app
WORKDIR /app
RUN mix local.hex --force  && \
    mix local.rebar --force && \
    mix deps.get && \
    mix test