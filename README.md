# Ilo Toki

A simple query engine using Toki Pona. The user can enter statements in the form of sentences without `seme`, and ask questions in the form of
sentences with it. Example I/O:
```
<- akesi li nasa
<- akesi li seme
 -> akesi li nasa
<- waso li moku e mi
<- waso li moku e seme
 -> waso li moku e mi
<- tomo mi li lili
<- seme li lili
 -> tomo mi li lili
```
The above demonstrates all types of queries available. Pretty useless, yeah - it was more of a learning exercise for me than anything.

## Building

To build the code, install Crystal, and then run `crystal build src/main.cr`.

## Known Issues

- Sentences with `mi` or `sina` as a subject must still use `li`.
- Sentences of the form `seme li <x> e seme` will not work.

## License

Do whatever.
