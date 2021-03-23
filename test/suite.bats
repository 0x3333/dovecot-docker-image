#!/usr/bin/env bash


@test "post_push hook is up-to-date" {
  run sh -c "cat Makefile | grep $DOCKERFILE: \
                          | cut -d ':' -f 2 \
                          | cut -d '\\' -f 1 \
                          | tr -d ' '"
  [ "$status" -eq 0 ]
  [ "$output" != '' ]
  expected="$output"

  run sh -c "cat '$DOCKERFILE/hooks/post_push' \
               | grep 'for tag in' \
               | cut -d '{' -f 2 \
               | cut -d '}' -f 1"
  [ "$status" -eq 0 ]
  [ "$output" != '' ]
  actual="$output"

  [ "$actual" == "$expected" ]
}


@test "dovecot runs ok" {
  run docker run --rm --entrypoint sh $IMAGE -c 'dovecot --version'
  [ "$status" -eq 0 ]
}

@test "dovecot has correct version" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    "dovecot --version | cut -d ' ' -f 1 \
                       | tr -d ' '"
  [ "$status" -eq 0 ]
  [ "$output" != '' ]
  actual="$output"

  run sh -c "cat Makefile | grep $DOCKERFILE: \
                          | cut -d ':' -f 2 \
                          | cut -d ',' -f 1 \
                          | cut -d '-' -f 1 \
                          | tr -d ' '"
  [ "$status" -eq 0 ]
  [ "$output" != '' ]
  expected="$output"

  [ "$actual.0" == "$expected" ]
}


@test "errors are logged to STDERR" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'doveconf | grep -Fx "log_path = /dev/stderr"'
  [ "$status" -eq 0 ]
}

@test "info logs are logged to STDOUT" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'doveconf | grep -Fx "info_log_path = /dev/stdout"'
  [ "$status" -eq 0 ]
}

@test "debug logs are logged to STDOUT" {
  run docker run --rm --entrypoint sh $IMAGE -c \
    'doveconf | grep -Fx "debug_log_path = /dev/stdout"'
  [ "$status" -eq 0 ]
}
