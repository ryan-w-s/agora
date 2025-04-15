// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/agora_web.ex",
    "../lib/agora_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        background: 'hsl(220, 40%, 10%)', // Dark Navy
        foreground: 'hsl(210 40% 98%)', // slate-50 adjusted
        card: 'hsl(220, 40%, 10%)', // Match background
        'card-foreground': 'hsl(210 40% 98%)',
        popover: 'hsl(220, 40%, 10%)', // Match background
        'popover-foreground': 'hsl(210 40% 98%)',
        primary: 'hsl(217.2 91.2% 59.8%)', // blue-500
        'primary-foreground': 'hsl(210 40% 98%)',
        secondary: 'hsl(217 32.6% 17.5%)', // slate-800 adjusted
        'secondary-foreground': 'hsl(210 40% 98%)',
        muted: 'hsl(217 32.6% 17.5%)',
        'muted-foreground': 'hsl(215 20.2% 65.1%)', // slate-400 adjusted
        accent: 'hsl(217 32.6% 17.5%)',
        'accent-foreground': 'hsl(210 40% 98%)',
        destructive: 'hsl(0 62.8% 30.6%)', // red-900 adjusted
        'destructive-foreground': 'hsl(210 40% 98%)',
        border: 'hsl(217 32.6% 17.5%)',
        input: 'hsl(217 32.6% 17.5%)',
        ring: 'hsl(217.2 91.2% 59.8%)', // blue-500 for focus rings
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
