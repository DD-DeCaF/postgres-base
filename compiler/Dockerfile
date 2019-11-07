FROM dddecaf/postgres-base:master

RUN set -eux \
    # Install build tools. These can be required for the `pip-compile` step in
    # child images that require to build packages from source.
    && apk add g++ postgresql-dev \
    # Re-run pip-compile in order to pre-populate the pip cache.
    && pip-compile --generate-hashes --output-file /dev/null \
      /opt/sql-requirements.txt
