import * as React from "react";

type Props = React.HTMLAttributes<HTMLDivElement>;

export function Card({ className = "", ...props }: Props) {
  return (
    <div
      className={
        "rounded-2xl border bg-white/60 p-6 shadow-sm " +
        "dark:bg-zinc-900/50 " +
        className
      }
      {...props}
    />
  );
}