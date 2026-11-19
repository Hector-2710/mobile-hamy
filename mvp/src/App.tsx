import { ChangeEvent, SVGProps, useEffect, useMemo, useRef, useState } from "react";

type IconProps = SVGProps<SVGSVGElement>;

const CameraIcon = (props: IconProps) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" {...props}>
    <path d="M4 7.8A1.8 1.8 0 0 1 5.8 6h2.1l1-1.7h6.2l1 1.7h2.1A1.8 1.8 0 0 1 20 7.8v9.4a1.8 1.8 0 0 1-1.8 1.8H5.8A1.8 1.8 0 0 1 4 17.2V7.8Z" />
    <circle cx="12" cy="12.5" r="3.4" />
  </svg>
);

const MapPinIcon = (props: IconProps) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" {...props}>
    <path d="M19 10c0 5-7 10-7 10S5 15 5 10a7 7 0 1 1 14 0Z" />
    <circle cx="12" cy="10" r="2.2" />
  </svg>
);

const CalendarIcon = (props: IconProps) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" {...props}>
    <rect x="3.5" y="5.5" width="17" height="15" rx="2.2" />
    <path d="M8 3.5v4M16 3.5v4M3.5 10h17" />
  </svg>
);

const XIcon = (props: IconProps) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
    <path d="m6 6 12 12M18 6 6 18" />
  </svg>
);

const ChevronIcon = (props: IconProps) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
    <path d="m9 18 6-6-6-6" />
  </svg>
);

const TrashIcon = (props: IconProps) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" {...props}>
    <path d="M4 7h16M9 3.5h6L16 7H8l1-3.5ZM7 7l.8 13h8.4L17 7M10 11v5M14 11v5" />
  </svg>
);

type Memory = {
  id: string;
  title: string;
  image: string;
  date: string;
  location: string;
  isPersonal?: boolean;
};

const seedMemories: Memory[] = [
  {
    id: "seed-1",
    title: "Nuestro lugar favorito",
    image:
      "https://images.unsplash.com/photo-1556229868-7b2d4b56b909?auto=format&fit=crop&w=900&q=84",
    date: "2025-06-14T20:42:00",
    location: "Playa de Bolonia, Cádiz",
  },
  {
    id: "seed-2",
    title: "Domingo sin prisa",
    image:
      "https://images.unsplash.com/photo-1490723186985-6d7672633c86?auto=format&fit=crop&w=900&q=84",
    date: "2025-05-25T12:18:00",
    location: "El Retiro, Madrid",
  },
  {
    id: "seed-3",
    title: "Un día de campo",
    image:
      "https://images.unsplash.com/photo-1693129551108-c1e0ab10f10e?auto=format&fit=crop&w=900&q=84",
    date: "2025-04-19T17:06:00",
    location: "Cercedilla, Madrid",
  },
  {
    id: "seed-4",
    title: "Hasta que se fue el sol",
    image:
      "https://images.unsplash.com/photo-1755189551092-79ae45166ce3?auto=format&fit=crop&w=900&q=84",
    date: "2025-03-08T19:51:00",
    location: "San Vicente, Ibiza",
  },
];

const dateFormatter = new Intl.DateTimeFormat("es-ES", {
  day: "numeric",
  month: "long",
  year: "numeric",
});

const timeFormatter = new Intl.DateTimeFormat("es-ES", {
  hour: "2-digit",
  minute: "2-digit",
});

const monthFormatter = new Intl.DateTimeFormat("es-ES", {
  month: "long",
  year: "numeric",
});

function formatMonth(date: string) {
  const label = monthFormatter.format(new Date(date));
  return label.charAt(0).toUpperCase() + label.slice(1);
}

function compressImage(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onerror = () => reject(new Error("No pudimos leer la imagen."));
    reader.onload = () => {
      const image = new Image();
      image.onerror = () => reject(new Error("No pudimos procesar la imagen."));
      image.onload = () => {
        const maxDimension = 1400;
        const scale = Math.min(1, maxDimension / Math.max(image.width, image.height));
        const canvas = document.createElement("canvas");
        canvas.width = Math.round(image.width * scale);
        canvas.height = Math.round(image.height * scale);
        const context = canvas.getContext("2d");
        if (!context) return reject(new Error("No pudimos procesar la imagen."));
        context.drawImage(image, 0, 0, canvas.width, canvas.height);
        resolve(canvas.toDataURL("image/jpeg", 0.78));
      };
      image.src = reader.result as string;
    };
    reader.readAsDataURL(file);
  });
}

export default function App() {
  const [memories, setMemories] = useState<Memory[]>(() => {
    try {
      const saved = localStorage.getItem("juntos-memories");
      return saved ? [...JSON.parse(saved), ...seedMemories] : seedMemories;
    } catch {
      return seedMemories;
    }
  });
  const [selectedMemory, setSelectedMemory] = useState<Memory | null>(null);
  const [draftImage, setDraftImage] = useState<string | null>(null);
  const [draftTitle, setDraftTitle] = useState("");
  const [draftDate, setDraftDate] = useState("");
  const [draftLocation, setDraftLocation] = useState("Buscando ubicación…");
  const [error, setError] = useState("");
  const fileInput = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const personalMemories = memories.filter((memory) => memory.isPersonal);
    try {
      localStorage.setItem("juntos-memories", JSON.stringify(personalMemories));
    } catch {
      // The album keeps working for this session if local storage is full.
    }
  }, [memories]);

  useEffect(() => {
    document.body.style.overflow = selectedMemory || draftImage ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [selectedMemory, draftImage]);

  const groupedMemories = useMemo(() => {
    return memories.reduce<Record<string, Memory[]>>((groups, memory) => {
      const month = formatMonth(memory.date);
      groups[month] = [...(groups[month] ?? []), memory];
      return groups;
    }, {});
  }, [memories]);

  const findLocation = () => {
    if (!navigator.geolocation) {
      setDraftLocation("Ubicación no disponible");
      return;
    }

    navigator.geolocation.getCurrentPosition(
      ({ coords }) => {
        const latitude = coords.latitude.toFixed(4);
        const longitude = coords.longitude.toFixed(4);
        setDraftLocation(`Ubicación actual · ${latitude}, ${longitude}`);
      },
      () => setDraftLocation("Ubicación no disponible"),
      { enableHighAccuracy: true, timeout: 9000, maximumAge: 60000 },
    );
  };

  const handlePhoto = async (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    event.target.value = "";
    if (!file) return;

    setError("");
    setDraftTitle("");
    setDraftDate(new Date().toISOString());
    setDraftLocation("Buscando ubicación…");
    findLocation();

    try {
      setDraftImage(await compressImage(file));
    } catch (caughtError) {
      setError(caughtError instanceof Error ? caughtError.message : "No pudimos abrir esa foto.");
    }
  };

  const saveMemory = () => {
    const title = draftTitle.trim();
    if (!title || !draftImage) {
      setError("Ponle un título a este recuerdo.");
      return;
    }

    const memory: Memory = {
      id: crypto.randomUUID(),
      title,
      image: draftImage,
      date: draftDate,
      location: draftLocation,
      isPersonal: true,
    };
    setMemories((current) => [memory, ...current]);
    setDraftImage(null);
    setDraftTitle("");
    setError("");
  };

  const deleteMemory = (memory: Memory) => {
    if (!memory.isPersonal) return;
    setMemories((current) => current.filter((item) => item.id !== memory.id));
    setSelectedMemory(null);
  };

  return (
    <main className="min-h-dvh bg-[#f7f3ed] text-[#29231f]">
      <input
        ref={fileInput}
        type="file"
        accept="image/*"
        capture="environment"
        onChange={handlePhoto}
        className="sr-only"
        aria-label="Tomar o elegir una foto"
      />

      <div className="mx-auto min-h-dvh max-w-[560px] bg-[#fbf8f3] shadow-[0_0_70px_rgba(61,45,34,0.08)]">
        <header className="relative overflow-hidden px-5 pb-7 pt-[max(1.5rem,env(safe-area-inset-top))] sm:px-7">
          <div className="absolute -right-24 -top-28 size-72 rounded-full bg-[#e2c5ad]/35 blur-3xl" />
          <div className="relative flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="grid size-11 place-items-center rounded-full border border-[#ded3c8] bg-white/70">
                <span className="font-serif text-xl italic text-[#a55e46]">J</span>
              </div>
              <div>
                <p className="text-[10px] font-semibold uppercase tracking-[0.22em] text-[#9d8d80]">
                  Nuestro álbum
                </p>
                <h1 className="font-serif text-[27px] leading-none tracking-[-0.03em]">Juntos</h1>
              </div>
            </div>
            <div className="flex -space-x-2" aria-label="Álbum compartido por dos personas">
              <div className="grid size-9 place-items-center rounded-full border-2 border-[#fbf8f3] bg-[#bd765d] text-xs font-bold text-white">
                L
              </div>
              <div className="grid size-9 place-items-center rounded-full border-2 border-[#fbf8f3] bg-[#52584c] text-xs font-bold text-white">
                M
              </div>
            </div>
          </div>

          <div className="relative mt-10 flex items-end justify-between gap-4">
            <div>
              <p className="font-serif text-[35px] leading-[1.02] tracking-[-0.04em]">
                Nuestra vida,
                <br />
                <em className="font-normal text-[#b16349]">en fotos.</em>
              </p>
              <p className="mt-3 max-w-[280px] text-[13px] leading-relaxed text-[#85776c]">
                Pequeños momentos que siempre querremos recordar.
              </p>
            </div>
            <button
              onClick={() => fileInput.current?.click()}
              className="group grid size-[62px] shrink-0 place-items-center rounded-full bg-[#a95d45] text-white shadow-[0_12px_28px_rgba(146,73,51,0.27)] transition hover:-translate-y-0.5 hover:bg-[#944f3b] active:scale-95"
              aria-label="Añadir una foto"
            >
              <CameraIcon className="size-6 transition-transform group-hover:scale-105" />
            </button>
          </div>
        </header>

        <div className="h-px bg-[#e9e0d7]" />

        <section className="px-5 pb-28 pt-7 sm:px-7">
          <div className="mb-7 flex items-center justify-between">
            <div>
              <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-[#ae9c8d]">
                Recuerdos
              </p>
              <p className="mt-1 text-sm text-[#61574f]">
                {memories.length}{" "}
                {memories.length === 1 ? "momento guardado" : "momentos guardados"}
              </p>
            </div>
            <button
              onClick={() => fileInput.current?.click()}
              className="flex items-center gap-2 rounded-full border border-[#ddd1c5] bg-white/60 px-4 py-2.5 text-xs font-semibold text-[#6e5f54] transition hover:border-[#bd765d] hover:text-[#a95d45]"
            >
              <CameraIcon className="size-4" />
              Nueva foto
            </button>
          </div>

          <div className="space-y-10">
            {Object.entries(groupedMemories).map(([month, monthMemories]) => (
              <div key={month}>
                <div className="mb-4 flex items-center gap-3">
                  <h2 className="font-serif text-[21px] tracking-[-0.02em]">{month}</h2>
                  <div className="h-px flex-1 bg-[#e6ddd4]" />
                  <span className="text-[10px] font-semibold text-[#aa9a8d]">
                    {monthMemories.length}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  {monthMemories.map((memory, index) => (
                    <button
                      key={memory.id}
                      onClick={() => setSelectedMemory(memory)}
                      className={`memory-card group relative overflow-hidden rounded-[20px] bg-[#dfd5ca] text-left ${
                        monthMemories.length === 1 || index % 3 === 0
                          ? "col-span-2 aspect-[1.5/1]"
                          : "aspect-[0.78/1]"
                      }`}
                    >
                      <img
                        src={memory.image}
                        alt={memory.title}
                        className="h-full w-full object-cover transition duration-700 group-hover:scale-[1.035]"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/5 to-transparent" />
                      <div className="absolute inset-x-0 bottom-0 p-4 text-white">
                        <h3 className="font-serif text-[20px] leading-tight tracking-[-0.01em] drop-shadow-sm">
                          {memory.title}
                        </h3>
                        <div className="mt-2 flex items-center gap-1.5 text-[10px] font-medium text-white/80">
                          <CalendarIcon className="size-3.5" />
                          <span>{dateFormatter.format(new Date(memory.date))}</span>
                          <span className="opacity-50">·</span>
                          <span>{timeFormatter.format(new Date(memory.date))}</span>
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </section>

        <div className="pointer-events-none fixed inset-x-0 bottom-0 z-20 mx-auto max-w-[560px] bg-gradient-to-t from-[#fbf8f3] via-[#fbf8f3]/95 to-transparent px-5 pb-[max(1rem,env(safe-area-inset-bottom))] pt-8">
          <button
            onClick={() => fileInput.current?.click()}
            className="pointer-events-auto flex h-14 w-full items-center justify-center gap-3 rounded-2xl bg-[#2e2b27] text-sm font-semibold text-white shadow-[0_12px_30px_rgba(45,39,34,0.2)] transition hover:bg-[#a95d45] active:scale-[0.99]"
          >
            <CameraIcon className="size-5" />
            Guardar un nuevo momento
          </button>
        </div>
      </div>

      {draftImage && (
        <div className="fixed inset-0 z-50 flex items-end justify-center bg-[#211c18]/60 backdrop-blur-sm sm:items-center sm:p-5">
          <div className="modal-in max-h-[96dvh] w-full max-w-[520px] overflow-y-auto rounded-t-[28px] bg-[#fbf8f3] shadow-2xl sm:rounded-[28px]">
            <div className="sticky top-0 z-10 flex items-center justify-between border-b border-[#e8dfd6] bg-[#fbf8f3]/95 px-5 py-4 backdrop-blur">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-[#a28e7f]">
                  Nuevo recuerdo
                </p>
                <h2 className="mt-0.5 font-serif text-2xl">Guarda este momento</h2>
              </div>
              <button
                onClick={() => setDraftImage(null)}
                className="grid size-10 place-items-center rounded-full bg-[#eee7df] text-[#5c5148] transition hover:bg-[#e5d9ce]"
                aria-label="Cerrar"
              >
                <XIcon className="size-5" />
              </button>
            </div>

            <div className="p-5">
              <div className="aspect-[4/3] overflow-hidden rounded-[20px] bg-[#e7ddd4]">
                <img
                  src={draftImage}
                  alt="Vista previa del nuevo recuerdo"
                  className="h-full w-full object-cover"
                />
              </div>

              <label className="mt-6 block">
                <span className="text-[11px] font-bold uppercase tracking-[0.18em] text-[#8f7e70]">
                  ¿Cómo se llama este recuerdo?
                </span>
                <input
                  autoFocus
                  value={draftTitle}
                  onChange={(event) => {
                    setDraftTitle(event.target.value);
                    setError("");
                  }}
                  onKeyDown={(event) => event.key === "Enter" && saveMemory()}
                  placeholder="Ej. Nuestro primer atardecer"
                  maxLength={60}
                  className="mt-2 w-full border-b border-[#cabbae] bg-transparent py-3 font-serif text-[23px] outline-none placeholder:text-[#b8aba0] focus:border-[#a95d45]"
                />
              </label>

              <div className="mt-5 space-y-2 rounded-2xl bg-[#f0e9e1] p-4 text-xs text-[#6f6258]">
                <div className="flex items-center gap-2.5">
                  <CalendarIcon className="size-4 text-[#a95d45]" />
                  <span>
                    {dateFormatter.format(new Date(draftDate))} ·{" "}
                    {timeFormatter.format(new Date(draftDate))}
                  </span>
                </div>
                <div className="flex items-center gap-2.5">
                  <MapPinIcon className="size-4 shrink-0 text-[#a95d45]" />
                  <span>{draftLocation}</span>
                </div>
              </div>

              {error && <p className="mt-3 text-xs font-medium text-[#a84f3d]">{error}</p>}

              <button
                onClick={saveMemory}
                className="mt-5 flex h-14 w-full items-center justify-center gap-2 rounded-2xl bg-[#a95d45] text-sm font-semibold text-white shadow-[0_10px_25px_rgba(153,76,54,0.22)] transition hover:bg-[#924c39] active:scale-[0.99]"
              >
                Guardar en nuestro álbum
                <ChevronIcon className="size-4" />
              </button>
              <p className="mt-3 text-center text-[10px] leading-relaxed text-[#a29387]">
                La fecha, hora y ubicación se añaden automáticamente.
              </p>
            </div>
          </div>
        </div>
      )}

      {selectedMemory && (
        <div className="fixed inset-0 z-50 bg-[#211c18] text-white">
          <img
            src={selectedMemory.image}
            alt={selectedMemory.title}
            className="absolute inset-0 h-full w-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-transparent to-black/80" />

          <div className="relative mx-auto flex h-full max-w-[700px] flex-col justify-between px-5 pb-[max(2rem,env(safe-area-inset-bottom))] pt-[max(1.5rem,env(safe-area-inset-top))] sm:px-8">
            <div className="flex justify-between">
              <button
                onClick={() => setSelectedMemory(null)}
                className="grid size-11 place-items-center rounded-full bg-black/25 backdrop-blur-md transition hover:bg-black/40"
                aria-label="Cerrar"
              >
                <XIcon className="size-5" />
              </button>
              {selectedMemory.isPersonal && (
                <button
                  onClick={() => deleteMemory(selectedMemory)}
                  className="grid size-11 place-items-center rounded-full bg-black/25 text-white/90 backdrop-blur-md transition hover:bg-[#9a4637]"
                  aria-label="Eliminar recuerdo"
                >
                  <TrashIcon className="size-5" />
                </button>
              )}
            </div>

            <div className="detail-in pb-4">
              <p className="mb-3 text-[10px] font-bold uppercase tracking-[0.24em] text-white/65">
                Nuestro recuerdo
              </p>
              <h2 className="max-w-[500px] font-serif text-[39px] leading-[1.05] tracking-[-0.03em] sm:text-5xl">
                {selectedMemory.title}
              </h2>
              <div className="mt-5 space-y-2 text-xs font-medium text-white/78">
                <div className="flex items-center gap-2">
                  <CalendarIcon className="size-4" />
                  <span>
                    {dateFormatter.format(new Date(selectedMemory.date))} ·{" "}
                    {timeFormatter.format(new Date(selectedMemory.date))}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <MapPinIcon className="size-4 shrink-0" />
                  <span>{selectedMemory.location}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
