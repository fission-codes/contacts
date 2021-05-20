import { execSync } from "child_process"
import elmPlugin from "vite-plugin-elm"


const elm = elmPlugin()


module.exports = {
  plugins: [
    {
      ...elm,
      transform: (...args) => {
        if (!args[1].endsWith(".elm")) return

        console.log(execSync(`just css`).toString())
        return elm.transform(...args)
      }
    }
  ],

  publicDir: "Static",

  // Build
  build: {
    minify: "esbuild",
    outDir: "build"
  }
}
