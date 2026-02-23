FROM haskell:9.14.1-slim-bookworm AS builder
RUN echo cabal update date: 2026-02-22
RUN cabal update --verbose=2

WORKDIR /hs-jpg2exif
COPY --link ./hs-jpg2exif.cabal ./
RUN cabal update --verbose=2
RUN cabal build --only-dependencies
COPY --link ./app/ ./app/
COPY --link ./src/ ./src/
COPY --link ./LICENSE ./
RUN cabal build
RUN cp $( cabal list-bin hs-jpg2exif | fgrep --max-count=1 hs-jpg2exif ) /usr/local/bin/
RUN which hs-jpg2exif

FROM debian:bookworm-slim
COPY --link --from=builder /usr/local/bin/hs-jpg2exif /usr/local/bin/

CMD ["/usr/local/bin/hs-jpg2exif"]
