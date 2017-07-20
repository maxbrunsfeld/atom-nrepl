## nrepl

This is an nrepl client for clojure development in atom.

### Status - Looking for a new maintainer

If anyone is familiar with Atom and the clojure eco-system and is interested in taking over maintaining and developing this package, I'd love for you to take over development!

### Usage

From your terminal, start an nrepl server in your project directory.

```shell
cd the-clojure-project
lein repl
```

In the editor, highlight part of your source file and trigger the `nrepl:eval` event (bound by default to `ctrl-alt-e`).
You will see the values of the highlighted expressions.

### Future Features

- Evaluate the top-level s-expression under the cursor
- Display `doc` for the symbol under the cursor
- Navigate to the source of the function under the cursor using its metadata
