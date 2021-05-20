const kit = require("fission-kit")


module.exports = {
  mode: "jit",
  darkMode: "media",


  purge: [
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
      }

    },
  },


  plugins: [

    require("@tailwindcss/forms")

  ]

}
