# Transpile javascript to GJS(Javascript for Gnome)

This transpile was based on [This Post](https://discourse.gnome.org/t/proposal-transition-gnome-shell-js-extensions-to-typescript-guide-for-extensions-today/4270)

## Will transpile:

PS: Character **`|`** means **or**
- `import * as ... from '|"...'|"`
- `import {...} from '|"...'|"`
- `export function`
- `export var`
- `export const`
- `Object.defineProperty(exports, "__esModule", { value: true });`
- `export class ...`

## Run script

**>>>** `transpile-gjs.sh "Me" "SOURCE_CODE_COMPILED_DIRECTORY"`

- Where **`Me`** its the variable from the line: `Me = imports.misc.extensionUtils.getCurrentExtension()`.
- The **`Me`** variable must be at the source code file, like this:
```
// @ts-ignore
const Me = imports.misc.extensionUtils.getCurrentExtension();
...
import ...
```

- `SOURCE_CODE_COMPILED_DIRECTORY` its **OPTIONAL** if run on **typescript** project with `tsconfig.json`

### Typescript

For typescript project, the `tsconfig.json` configuration:

```json
{
    "version": "1.0.0",
    "compileOnSave": true,
    "compilerOptions": {
        "target": "es2015",
        "strict": true,
        "outDir": "dist",
        "forceConsistentCasingInFileNames": true,
        "downlevelIteration": true,
        "lib": [
            "ES6"
        ],
        "pretty": true,
        "removeComments": true,
        "incremental": true,
        "noUnusedLocals": true,
        "noUnusedParameters": true,
        "sourceMap": true,
        "declaration": true,
    },
    "include": [
        "src/*.ts"
    ]
}
```