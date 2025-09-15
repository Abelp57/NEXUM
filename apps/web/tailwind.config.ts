import type { Config } from "tailwindcss";

export default {
  darkMode: ["class"],
  content: [
    "./app/**/*.{ts,tsx,js,jsx,mdx}",
    "./pages/**/*.{ts,tsx,js,jsx,mdx}",
    "./components/**/*.{ts,tsx,js,jsx,mdx}",
    "../../packages/ui/**/*.{ts,tsx,js,jsx,mdx}"
  ],
  theme: { extend: {} },
  plugins: [],
} satisfies Config;