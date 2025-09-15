import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"

export default function NexumLanding() {
  return (
    <main className="mx-auto max-w-7xl px-4 py-20 space-y-10">
      <section className="text-center">
        <h1 className="text-5xl font-extrabold text-nx-primary-600">NEXUM</h1>
        <p className="mt-4 text-lg text-slate-600">
          Conecta tu negocio con cualquier vertical.
        </p>
        <div className="mt-6 flex justify-center gap-4">
          <Button variant="default">Comenzar gratis</Button>
          <Button variant="secondary">Ver planes</Button>
        </div>
      </section>

      <section className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <h2 className="text-xl font-semibold mb-2">💳 Ventas rápidas</h2>
          <p className="text-slate-600">Cobra con tarjeta y efectivo sin fricción.</p>
        </Card>
        <Card>
          <h2 className="text-xl font-semibold mb-2">📦 Inventario</h2>
          <p className="text-slate-600">Control en tiempo real con alertas.</p>
        </Card>
        <Card>
          <h2 className="text-xl font-semibold mb-2">📊 Reportes claros</h2>
          <p className="text-slate-600">Analiza ventas y márgenes en segundos.</p>
        </Card>
      </section>
    </main>
  )
}
