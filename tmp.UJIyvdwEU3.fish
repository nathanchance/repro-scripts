#!/usr/bin/env fish

set urls \
    https://builds.tuxbuild.com/2F7kYaoIfpmVWnZwoDzzZMDQ6q2 \
    https://builds.tuxbuild.com/2F7tt3TKcI9Si6PeXySCiKJdtcx \
    https://builds.tuxbuild.com/2F7juJYj7kRIX2bohYENJ6X81Xr \
    https://builds.tuxbuild.com/2F7j9YjIlInKSQFUGL6VRtrjwwb \
    https://builds.tuxbuild.com/2F7iMLYS5pnJzFgud8w4S8pFo7X \
    https://builds.tuxbuild.com/2F7FVpOFinNn51Gqk4KzCUar7nt \
    https://builds.tuxbuild.com/2FAeKXPFFSZ0WmCbx3fowfAWmG9 \
    https://builds.tuxbuild.com/2FAqtVw7y6k2DYDbD7IkOD1EQgh \
    https://builds.tuxbuild.com/2FAg4jav8UVXgn1UOOR7k9fjGbA \
    https://builds.tuxbuild.com/2FApl8k7yRyzEVGfxrJ5HC42WT5 \
    https://builds.tuxbuild.com/2FAX44tDK8Lz2IO8CTvxQLuLXGI \
    https://builds.tuxbuild.com/2FAhxW4vpHz0tyYyc3vAnpJPKGk \
    https://builds.tuxbuild.com/2F3pXR7CTARVHhLlKg8JDbj7NTz \
    https://builds.tuxbuild.com/2F3dgG7mWmtiN2DOrlgUlIc0QKe \
    https://builds.tuxbuild.com/2F3sXkt36DYoYj5AuuDJJH5YLOK \
    https://builds.tuxbuild.com/2F3WgvJOBe0nGWU56bjQsH2XDbo \
    https://builds.tuxbuild.com/2FAitTCvj1isFnQ7oeLp8kprBqR \
    https://builds.tuxbuild.com/2FAXKscAGo3uWLmodUbHGsezvdk \
    https://builds.tuxbuild.com/2F3tU78pLDIHAiigEAKHEAuFVfF \
    https://builds.tuxbuild.com/2F3Zm2UZDAeidhrtoMqJWrPVuVJ \
    https://builds.tuxbuild.com/2F3XPf520MYw5hyc8vaZhVTnpXX \
    https://builds.tuxbuild.com/2F3azewTSXOfqFRFWaIkzVqrevU \
    https://builds.tuxbuild.com/2FAnPm56ehjg7RCVTN5F0P5PPS5 \
    https://builds.tuxbuild.com/2FAWcwEPGJnO0llyLwhnqGKu5hC \
    https://builds.tuxbuild.com/2F3XFTDxePfJKl7vHq5DtlydXM1 \
    https://builds.tuxbuild.com/2F3oHwKEGC4jYBavjJvrffb4KDS \
    https://builds.tuxbuild.com/2F3pDV75ML6ppuRWBT56yTxiPpH \
    https://builds.tuxbuild.com/2F3n3AG6T0OoJ7wlKZovtmHF6tA \
    https://builds.tuxbuild.com/2FAXREhuENwzTpvrAJvpsC4J7OY \
    https://builds.tuxbuild.com/2FAtY6lKGbuwW6MqQ0GV3APIdpS \
    https://builds.tuxbuild.com/2F3brNWzXOwzT2VNRIBcBPcafRb \
    https://builds.tuxbuild.com/2F3uR1w0SnUBVKWzAcmDB3BWXsl \
    https://builds.tuxbuild.com/2FAg92awBqMXvWBEuxEjmH8CObD \
    https://builds.tuxbuild.com/2FAXt5oAYwovd5GvDCzq21Ai287 \
    https://builds.tuxbuild.com/2F3uNZ6GVHeml8PLbuXlp6p918L \
    https://builds.tuxbuild.com/2F3njQdxvq6Yin9kFAKQIKi3VIG \
    https://builds.tuxbuild.com/2FAgAvU3pJRPcZvqskjor7xBDoQ \
    https://builds.tuxbuild.com/2FAYApi74LCJNew7JeZAZF2IyeI \
    https://builds.tuxbuild.com/2F3aLFy70WkHseWqbBhZFuXxp5Z \
    https://builds.tuxbuild.com/2F3yzQipMGra1oxudZ8ZrrC7zvy \
    https://builds.tuxbuild.com/2FAdMhZzObKeUqq23bSvIPMoZuy \
    https://builds.tuxbuild.com/2FAp93VLAyLAhcFzLD9PUwFB3qZ

set krnl $TMP_FOLDER/zImage.epapr

set fish_trace 1
for url in $urls
    crl -o $krnl $url/(basename $krnl); or return

    $CBL_GIT/boot-utils/boot-qemu.py \
        -a ppc64le \
        -k $krnl \
        -t 90s &| rg "Linux version "
    switch "$pipestatus"
        case "0 0"
            continue
        case "*"
            return 1
    end
end
