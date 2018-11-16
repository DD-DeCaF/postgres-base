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

FROM dddecaf/wsgi-base:master

WORKDIR /opt

COPY sql-requirements.in ./

# `g++` is required for building `psycopg2` but all build dependencies are
# later removed again to reduce the layer size.
RUN set -eux \
    && apk add --no-cache --virtual .build-deps postgresql-dev g++ \
    && pip-compile --generate-hashes \
        --output-file sql-requirements.txt sql-requirements.in \
    && pip-sync sql-requirements.txt \
    && rm -rf /root/.cache \
    && apk del .build-deps
