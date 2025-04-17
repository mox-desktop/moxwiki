FROM rust:latest

WORKDIR /app

COPY . .

RUN cargo install mdbook

CMD ["mdbook", "serve", "--hostname", "0.0.0.0", "--port", "3000"]

EXPOSE 3000
