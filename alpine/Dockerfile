# Copyright 2018 Novo Nordisk Foundation Center for Biosustainability, DTU.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM dddecaf/wsgi-base:alpine

WORKDIR /opt

COPY sql-requirements.in ./

RUN set -eux \
    # Install build dependencies to make sure we can build packages that don't
    # provide pre-built wheels from source.
    && apk add --no-cache --virtual .build-deps build-base postgresql-dev \
    # Install postgres libs for psycopg2. Note that these are needed at runtime.
    && apk add --no-cache postgresql \
    # Compile the dependencies for base + SQL.
    && pip-compile --generate-hashes \
        --output-file sql-requirements.txt sql-requirements.in \
    # Pre-install the compiled requirements to save some build time for child
    # images.
    && pip-sync sql-requirements.txt \
    # Remove build dependencies and the pip cache to reduce layer size.
    && apk del .build-deps \
    && rm -rf /root/.cache
