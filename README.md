# MacOS mouse debouncer
Debounces left clicks when they happen less than 150ms apart.

## Why?
My left button switch started to malfunction and rather than getting create waste. I tried creating a debounce modification in Karabiner Elements without success, so I asked my friendly LLM to build a debouncer. After tweaking the code a bit it works just as I want it without any weird events.

## Build
```bash
git clone https://github.com/augusto/MacOS-mouse-debouncer.git
cd MacOS-mouse-debouncer
./build
./debounce
```
