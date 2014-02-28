## nrepl

This is an nrepl client for clojure development in atom.

### usage

From your terminal, start an nrepl server in your project directory.

```shell
cd the-clojure-project
lein repl
```

In the editor, highlight part of your source file and trigger the `nrepl:eval` event (bound by default to `ctrl-alt-e`).
You will see the values of the highlighted expressions.

### future features

- Evaluate the top-level s-expression under the cursor
- Display `doc` for the symbol under the cursor
- Navigate to the source of the function under the cursor using its metadata
