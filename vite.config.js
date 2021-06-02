import { execSync } from "child_process"
import elmPlugin from "vite-plugin-elm"


const elm = elmPlugin()
const originalTransform = elm.transform


elm.transform = function(...args) {
  if (!args[1].endsWith(".elm")) return

  console.log(execSync(`just css`).toString())
  return originalTransform.apply(this, args)
}


module.exports = {

  plugins: [
    elm
  ],

  publicDir: "Static",

  // Build
  build: {
    outDir: "build",
    target: "es2020"
  },

}
