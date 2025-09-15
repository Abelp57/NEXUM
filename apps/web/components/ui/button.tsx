import * as React from "react";

type Variant = "default" | "secondary" | "outline";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  asChild?: boolean;
  variant?: Variant;
};

const variants: Record<Variant, string> = {
  default:
    "bg-black text-white hover:bg-black/90 dark:bg-white dark:text-black",
  secondary:
    "bg-white text-black border hover:bg-gray-50 dark:bg-zinc-900 dark:text-white",
  outline:
    "bg-transparent border text-black dark:text-white hover:bg-black/5 dark:hover:bg-white/5",
};

export function Button({ className = "", variant = "default", ...props }: Props) {
  const v = variants[variant] ?? variants.default;
  return (
    <button
      className={
        "inline-flex items-center justify-center gap-2 rounded-xl px-4 py-2 text-sm font-medium shadow-sm " +
        v + (className ? " " + className : "")
      }
      {...props}
    />
  );
}