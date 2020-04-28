FROM dddecaf/postgres-base:master

RUN set -eux \
    # Install build tools. These can be required for the `pip-compile` step in
    # child images that require to build packages from source.
    && apk add --no-cache build-base libffi-dev postgresql-dev \
    # Re-run pip-compile in order to pre-populate the pip cache.
    && pip-compile --generate-hashes --verbose --output-file /dev/null \
      /opt/sql-requirements.txt
