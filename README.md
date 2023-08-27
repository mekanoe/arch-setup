# mekanoe arch

this is for my benefit alone, but if you want to use it, go ahead.

a lot of this is ported out from nyarch linux because they did stuff in a way i enjoy

## starting in livecd (pre-chroot)

```bash
# setup wifi FIRST. check with ping to mekanoe.com
curl -sSL https://mekanoe.com/archstrap | bash
```

## starting in chroot

```bash
curl -sSL https://mekanoe.com/archstrap | WHICH=fresh bash
```

## starting from booted environment

```bash
curl -sSL https://mekanoe.com/archstrap | WHICH=setup bash
```
