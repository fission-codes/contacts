const plugin = require("tailwindcss/plugin")
const kit = require("fission-kit")


module.exports = {
  mode: "jit",
  darkMode: "media",


  purge: [
    "src/**/*.html",
    "src/Application/**/*.elm"
  ],


  theme: {

    colors: {
      ...kit.dasherizeObjectKeys(kit.colors),

      current: "currentColor",
      inherit: "inherit",
      transparent: "transparent",
    },

    extend: {

      fontFamily: {
        body: [ kit.fonts.body ],
        display: [ kit.fonts.display ],
        mono: [ kit.fonts.mono ],
      },

      screens: {
        "no-hover": { "raw": "(hover: none)" },
      }

    },
  },


  plugins: [

    require("@tailwindcss/forms"),

    // Add custom font
    plugin(function({ addBase }) {
      kit.fontFaces({ fontsPath: "/fonts/" }).forEach(fontFace => {
        addBase({ "@font-face": fontFace })
      })

    })

  ]

}
