---
name: react-pwa
description: "Padrão para apps PWA em React + Vite + TypeScript com vite-plugin-pwa: manifest, service worker (generateSW, registro pelo app), aviso de \"Nova versão disponível\" com Atualizar/Agora não, verificação periódica de atualização, exibição da versão atual vinda do GitVersion (tela de configurações/conta), build args no Docker/CI, cache do nginx e testes. Use para transformar um frontend React em PWA ou revisar um PWA existente."
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
user-invocable: true
---

# react-pwa — padrão de PWA em React

Padrão consolidado dos projetos finami, pontua e gwr-webapp. Complementa a skill
`react-architecture` (Types, Services, Contexts, Hooks) e usa a versão gerada pela skill `gitversion`.

## Entrada

Contexto opcional em `$ARGUMENTS` (ex.: nome do app, cores, atalhos). Sem argumentos, aplique o
padrão completo no frontend do projeto atual.

## 0. Antes de começar

1. Leia `package.json`, `vite.config.ts`, `src/main.tsx`, `src/App.tsx`, `src/vite-env.d.ts`, a pasta
   de i18n e a tela de configurações/conta do usuário. **Siga o que já existe** (componentes `Button`,
   utilitário de notificação, tokens do Tailwind).
2. Confirme que o repositório usa GitVersion (`GitVersion.yml` + tags `vX.Y.Z`). Se não usar, invoque a
   skill `gitversion` antes — a versão exibida no app vem dessas tags.
3. Ícones (`any` e `maskable` 192/512, atalhos 96) são entregues pelo `ux-designer`; não invente imagens.
4. Instale: `npm i -D vite-plugin-pwa` e `npm i workbox-window`.

## 1. Decisões do padrão

| Item | Padrão |
|---|---|
| Plugin | `vite-plugin-pwa`, `strategies: "generateSW"` |
| Atualização | `registerType: "prompt"` — o usuário decide; **nunca** `autoUpdate` (recarrega sem avisar) |
| Registro do SW | `injectRegister: false`; feito pelo app com `useRegisterSW` (`virtual:pwa-register/react`) **uma única vez**, num Provider |
| Dev | `devOptions: { enabled: false }` — sem service worker em `npm run dev` |
| Busca de versão nova | a cada **1 hora** e quando a aba volta a ficar visível (sem internet, não busca) |
| Aviso | "Nova versão disponível" · **Atualizar** · **Agora não** — não modal, `role="status"`, não rouba o foco |
| Versão do app | `__APP_VERSION__` (define do Vite), sem o `v`; exibida como `v1.4.2` em Configurações/Conta |
| Origem da versão | `VITE_APP_VERSION` (build arg/CI) → tag do git (`git describe`) → `version` do `package.json` |
| Precache | só a "casca" (JS, CSS, HTML, fontes, ícones); API **nunca** passa pelo SW |
| Cache HTTP | `sw.js`, `registerSW.js`, `workbox-*.js`, `manifest.webmanifest` e `index.html` com `no-cache` |

## 2. `vite.config.ts`

```ts
import { execSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { VitePWA } from "vite-plugin-pwa";

/** Cor das barras do sistema (token de superfície do design) */
const THEME_COLOR = "#FFFFFF";
/** Cor do splash (token de fundo do design) */
const BACKGROUND_COLOR = "#F3F6F9";

/** `version` do package.json: último recurso quando não há VITE_APP_VERSION nem tag */
const readPackageVersion = (): string => {
  try {
    const pkg = JSON.parse(readFileSync(new URL("./package.json", import.meta.url), "utf-8")) as { version?: string };
    return pkg.version || "0.0.0";
  } catch {
    return "0.0.0";
  }
};

/**
 * Tag do GitVersion (vX.Y.Z): a mais próxima do commit atual ou, se a branch ainda não tiver tag,
 * a maior do repositório. Sem git (build no Docker, que ignora .git) devolve null.
 */
const readGitTagVersion = (): string | null => {
  const run = (command: string): string => {
    try {
      return execSync(command, { stdio: ["ignore", "pipe", "ignore"] }).toString().trim();
    } catch {
      return "";
    }
  };
  const nearest = run('git describe --tags --abbrev=0 --match "v[0-9]*"');
  if (nearest) return nearest;
  return run('git tag --list "v[0-9]*" --sort=-v:refname').split(/\r?\n/)[0] || null;
};

export default defineConfig(({ mode }) => {
  // loadEnv também lê o process.env (o CI/Docker passa VITE_APP_VERSION)
  const env = loadEnv(mode, process.cwd(), "VITE_");
  const appVersion = (env.VITE_APP_VERSION || readGitTagVersion() || readPackageVersion()).trim().replace(/^v/i, "");

  return {
    define: {
      __APP_VERSION__: JSON.stringify(appVersion),
    },
    plugins: [
      react(),
      tailwindcss(),
      VitePWA({
        registerType: "prompt",
        injectRegister: false,
        strategies: "generateSW",
        devOptions: { enabled: false },
        // Os PNGs de public/ entram pelo globPatterns (evita entradas duplicadas no precache)
        includeManifestIcons: false,
        workbox: {
          globPatterns: ["**/*.{js,css,html,svg,png,ico,webp,woff2}"],
          // Tudo que só serve na instalação ou para crawlers fica fora do precache
          globIgnores: ["**/node_modules/**/*", "screenshots/**", "splash/**", "og-image.png"],
          navigateFallback: "/index.html",
          // Rotas do backend na mesma origem nunca são servidas pelo SW
          navigateFallbackDenylist: [/^\/api\//, /^\/health/, /^\/healthz/, /^\/swagger/],
          cleanupOutdatedCaches: true,
        },
        manifest: {
          id: "/",
          name: "{App Name}",
          short_name: "{App}",
          description: "{Descrição curta do app}",
          lang: "pt-BR",
          dir: "ltr",
          start_url: "/?source=pwa",
          scope: "/",
          display: "standalone",
          display_override: ["standalone"],
          theme_color: THEME_COLOR,
          background_color: BACKGROUND_COLOR,
          icons: [
            { src: "/icon-any-192.png", sizes: "192x192", type: "image/png", purpose: "any" },
            { src: "/icon-any-512.png", sizes: "512x512", type: "image/png", purpose: "any" },
            { src: "/icon-maskable-192.png", sizes: "192x192", type: "image/png", purpose: "maskable" },
            { src: "/icon-maskable-512.png", sizes: "512x512", type: "image/png", purpose: "maskable" },
          ],
          // shortcuts / screenshots / orientation / categories: conforme o app
        },
      }),
    ],
    test: {
      environment: "jsdom",
      setupFiles: "./src/test/setup.ts",
      globals: true,
      css: false,
      // Módulo virtual do plugin substituído por um mock nos testes (seção 9)
      alias: [{ find: "virtual:pwa-register/react", replacement: "/src/test/pwaRegisterMock.ts" }],
    },
  };
});
```

- App com bundle grande (ex.: Three.js): `maximumFileSizeToCacheInBytes` no `workbox`.
- Assets pesados (imagens remotas, modelos 3D, fontes externas): `runtimeCaching` com `CacheFirst` e
  `expiration`, nunca no precache. APIs **não** entram em `runtimeCaching`.

## 3. `src/vite-env.d.ts`

```ts
/// <reference types="vite/client" />
/// <reference types="vite-plugin-pwa/react" />
/// <reference types="vite-plugin-pwa/info" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_SITE_BASENAME?: string;
  /** Versão do app (tag do GitVersion, com ou sem "v"). Lida no vite.config.ts → __APP_VERSION__ */
  readonly VITE_APP_VERSION?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

/** Versão do app, sem o "v" (define do vite.config.ts) */
declare const __APP_VERSION__: string;
```

## 4. `src/utils/appVersion.ts`

```ts
/** Versão do app vinda do build (vite.config.ts → __APP_VERSION__), sem o "v" */
export const APP_VERSION: string =
  typeof __APP_VERSION__ === "string" && __APP_VERSION__ ? __APP_VERSION__ : "0.0.0";

/** Versão formatada para exibição: "v1.4.2" */
export const APP_VERSION_LABEL = `v${APP_VERSION}`;
```

Nunca leia a versão de `import.meta.env` nos componentes: use sempre `APP_VERSION`.

## 5. `src/hooks/useAppUpdate.ts`

```ts
import { useCallback, useEffect, useMemo, useState } from "react";
import { useRegisterSW } from "virtual:pwa-register/react";

/** Intervalo da busca por versão nova do app */
export const UPDATE_CHECK_INTERVAL_MS = 60 * 60 * 1000;

export interface AppUpdate {
  /** Há uma versão nova esperando (SW novo instalado em `waiting`) */
  needRefresh: boolean;
  /** O app ficou pronto para abrir sem internet (primeiro precache concluído) */
  offlineReady: boolean;
  /** "Atualizar" em andamento (o app vai recarregar) */
  updating: boolean;
  /** Ativa o SW novo e recarrega na mesma rota; `false` se falhou antes de recarregar */
  update: () => Promise<boolean>;
  /** "Agora não": esconde o aviso; a versão nova entra na próxima abertura do zero */
  dismiss: () => void;
}

/** Registro do service worker e atualização controlada. Usado uma única vez, pelo AppUpdateProvider. */
export const useAppUpdate = (): AppUpdate => {
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null);
  const [updating, setUpdating] = useState(false);
  const {
    needRefresh: [needRefresh, setNeedRefresh],
    offlineReady: [offlineReady, setOfflineReady],
    updateServiceWorker,
  } = useRegisterSW({
    onRegisteredSW: (_swUrl, swRegistration) => {
      if (swRegistration) setRegistration(swRegistration);
    },
  });

  useEffect(() => {
    if (!registration) return undefined;
    const check = () => {
      // Sem internet ou com uma instalação em andamento não há o que buscar
      if (registration.installing || navigator.onLine === false) return;
      registration.update().catch(() => undefined);
    };
    const onVisibilityChange = () => {
      if (document.visibilityState === "visible") check();
    };
    const interval = setInterval(check, UPDATE_CHECK_INTERVAL_MS);
    document.addEventListener("visibilitychange", onVisibilityChange);
    return () => {
      clearInterval(interval);
      document.removeEventListener("visibilitychange", onVisibilityChange);
    };
  }, [registration]);

  const update = useCallback(async (): Promise<boolean> => {
    setUpdating(true);
    try {
      await updateServiceWorker(true);
      return true;
    } catch {
      setUpdating(false);
      return false;
    }
  }, [updateServiceWorker]);

  const dismiss = useCallback(() => {
    setNeedRefresh(false);
    setOfflineReady(false);
  }, [setNeedRefresh, setOfflineReady]);

  return useMemo(
    () => ({ needRefresh, offlineReady, updating, update, dismiss }),
    [needRefresh, offlineReady, updating, update, dismiss],
  );
};

export default useAppUpdate;
```

## 6. `src/Contexts/AppUpdateContext.tsx` e registro no `App.tsx`

```tsx
import { createContext } from "react";
import type { ReactNode } from "react";
import { useAppUpdate } from "../hooks/useAppUpdate";
import type { AppUpdate } from "../hooks/useAppUpdate";

/** Estado da atualização do app (um único registro do SW) para o aviso e a tela de configurações */
const AppUpdateContext = createContext<AppUpdate | undefined>(undefined);

export const AppUpdateProvider = ({ children }: { children: ReactNode }) => {
  const value = useAppUpdate();
  return <AppUpdateContext.Provider value={value}>{children}</AppUpdateContext.Provider>;
};

export default AppUpdateContext;
```

No `App.tsx`, o `AppUpdateProvider` fica **acima do roteador**, e o `UpdatePrompt` é renderizado em cada
casca (layout autenticado, layout de login, página offline) ou uma vez no `App.tsx` se houver uma casca só:

```tsx
const App = () => (
  <AppUpdateProvider>
    <RouterProvider router={router} />
  </AppUpdateProvider>
);
```

Não chame `useRegisterSW` nem `registerSW` em nenhum outro lugar (registraria o SW duas vezes).

## 7. Aviso de nova versão — `src/components/pwa/UpdatePrompt.tsx`

```tsx
import { useContext, useId } from "react";
import { RefreshCw } from "lucide-react";
import { useTranslation } from "react-i18next";
import AppUpdateContext from "../../Contexts/AppUpdateContext";
import { Button } from "../ui/Button";
import { notifyError } from "../../utils/notify";

/**
 * "Nova versão disponível · Atualizar · Agora não". Não modal e não move o foco: a região viva fica
 * sempre montada e só o conteúdo entra. Durante "Atualizar" o cartão continua, só "Agora não" sai.
 * Fora do AppUpdateProvider não renderiza nada.
 */
export const UpdatePrompt = () => {
  const { t } = useTranslation();
  const appUpdate = useContext(AppUpdateContext);
  const textId = useId();
  const visible = appUpdate !== undefined && (appUpdate.needRefresh || appUpdate.updating);

  if (!appUpdate) return null;
  const { updating, update, dismiss } = appUpdate;

  const runUpdate = async () => {
    const ok = await update();
    if (!ok) notifyError(t("pwa.update.failed"));
  };

  return (
    <div role="status" aria-live="polite" aria-labelledby={visible ? textId : undefined}>
      {visible ? (
        <div className="fixed inset-x-3 bottom-[calc(env(safe-area-inset-bottom)+12px)] z-40 flex flex-col gap-2 rounded-xl border border-border bg-surface p-3 shadow-lg md:inset-x-auto md:right-6 md:bottom-6 md:w-[360px]">
          <p id={textId} className="m-0 flex items-center gap-2.5 font-semibold text-text">
            <RefreshCw aria-hidden="true" className="size-5 shrink-0 text-primary" />
            {t("pwa.update.available")}
          </p>
          <div className="flex justify-end gap-2">
            {!updating ? (
              <Button variant="ghost" size="sm" onClick={dismiss}>
                {t("pwa.update.notNow")}
              </Button>
            ) : null}
            <Button size="sm" loading={updating} loadingText={t("pwa.update.updating")} onClick={() => void runUpdate()}>
              {t("pwa.update.update")}
            </Button>
          </div>
        </div>
      ) : null}
    </div>
  );
};

export default UpdatePrompt;
```

- Posição: acima da tab bar/FAB no mobile (some `--tabbar-h` ao `bottom`) e canto inferior no desktop.
- Visual (cores, raio, sombra) vem dos tokens do projeto / especificação do `ux-designer`.

## 8. Versão atual na tela de Configurações / Conta

Toda tela de configurações (ou de conta do usuário, se não houver configurações) DEVE ter uma linha
**Versão** com a versão atual e, quando houver versão nova esperando, a ação de atualizar:

```tsx
import { useContext } from "react";
import { useTranslation } from "react-i18next";
import AppUpdateContext from "../../Contexts/AppUpdateContext";
import { APP_VERSION_LABEL } from "../../utils/appVersion";

export const AppVersionRow = () => {
  const { t } = useTranslation();
  const appUpdate = useContext(AppUpdateContext);
  const hasUpdate = appUpdate?.needRefresh === true;

  return (
    <div className="flex items-center justify-between gap-3 py-3">
      <span className="text-text-muted">{t("pwa.version.label")}</span>
      <span className="flex items-center gap-2">
        <span className="tabular-nums text-text">{APP_VERSION_LABEL}</span>
        {hasUpdate ? (
          <button type="button" className="font-semibold text-primary underline" disabled={appUpdate.updating} onClick={() => void appUpdate.update()}>
            {t("pwa.version.updateAvailable")}
          </button>
        ) : null}
      </span>
    </div>
  );
};
```

- Formato sempre `v{X.Y.Z}`, sem hash de commit nem data.
- Opcional: rodapé da tela com `{Nome do app} · v{X.Y.Z}` (gwr-webapp).
- A tela de login pode mostrar a versão discreta no rodapé (ajuda no suporte).

## 9. Textos (i18n)

```json
{
  "pwa": {
    "update": {
      "available": "Nova versão disponível",
      "update": "Atualizar",
      "updating": "Atualizando…",
      "notNow": "Agora não",
      "failed": "Não foi possível atualizar. Tente de novo."
    },
    "version": {
      "label": "Versão",
      "updateAvailable": "Atualizar agora"
    }
  }
}
```

Adapte as chaves ao formato do projeto (namespace `pwa:` no pontua, chave `pwa.` no finami) via skill
`add-react-i18n`.

## 10. Build, Docker, CI e nginx

**Dockerfile** (o `.git` não entra na imagem, então a versão vem por build arg):

```dockerfile
# Versão exibida no app (tag do GitVersion). Vazia, vale a do package.json
ARG VITE_APP_VERSION=
ENV VITE_APP_VERSION=$VITE_APP_VERSION
RUN npm run build
```

**CI** (pipeline de deploy — `k8s-deploy` ou `deploy-prod`): checkout com histórico e tags e repasse da
última tag do GitVersion como build arg:

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0   # git describe precisa das tags
- id: meta
  run: echo "version=$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || true)" >> "$GITHUB_OUTPUT"
# ...docker/build-push-action:
#   build-args: |
#     VITE_APP_VERSION=${{ steps.meta.outputs.version }}
```

**docker-compose** (homolog local): `VITE_APP_VERSION: ${APP_VERSION:-}` nos `args` e
`APP_VERSION=$(git describe --tags --abbrev=0) docker compose up -d --build`.

**nginx** — o service worker, o manifest e o `index.html` nunca podem ficar presos em cache, senão o
usuário não recebe a versão nova:

```nginx
location /assets/ {
    try_files $uri =404;
    add_header Cache-Control "public, max-age=31536000, immutable";
}
location ~* ^/(sw\.js|registerSW\.js|workbox-[^/]+\.js)$ {
    try_files $uri =404;
    add_header Cache-Control "no-cache";
}
location = /manifest.webmanifest {
    default_type application/manifest+json;
    types { }
    try_files $uri =404;
    add_header Cache-Control "no-cache";
}
location / {
    try_files $uri $uri/ /index.html;
    add_header Cache-Control "no-cache";
}
```

(`add_header` num `location` substitui os do `server`: repita os cabeçalhos de segurança neles.)

## 11. Testes (Vitest + Testing Library)

`src/test/pwaRegisterMock.ts` substitui `virtual:pwa-register/react` (alias no `vite.config.ts`):

```ts
import { useEffect, useState } from "react";
import type { Dispatch, SetStateAction } from "react";
import { vi } from "vitest";
import type { RegisterSWOptions } from "virtual:pwa-register/react";

export interface PwaRegisterState {
  needRefresh: boolean;
  offlineReady: boolean;
}

const INITIAL_STATE: PwaRegisterState = { needRefresh: false, offlineReady: false };
let state: PwaRegisterState = { ...INITIAL_STATE };
let options: RegisterSWOptions | undefined;
const setters = new Set<(next: PwaRegisterState) => void>();

export const updateServiceWorkerMock = vi.fn(async (_reloadPage?: boolean): Promise<void> => undefined);

/** Define o estado devolvido pelo hook (também atualiza componentes já montados) */
export const setPwaRegisterState = (next: Partial<PwaRegisterState>): void => {
  state = { ...state, ...next };
  setters.forEach((set) => set(state));
};

export const lastRegisterOptions = (): RegisterSWOptions | undefined => options;

/** Chamar no afterEach do setup.ts */
export const resetPwaRegisterMock = (): void => {
  state = { ...INITIAL_STATE };
  options = undefined;
  setters.clear();
  updateServiceWorkerMock.mockClear();
};

export const useRegisterSW = (registerOptions?: RegisterSWOptions): {
  needRefresh: [boolean, Dispatch<SetStateAction<boolean>>];
  offlineReady: [boolean, Dispatch<SetStateAction<boolean>>];
  updateServiceWorker: (reloadPage?: boolean) => Promise<void>;
} => {
  options = registerOptions;
  const [needRefresh, setNeedRefresh] = useState(state.needRefresh);
  const [offlineReady, setOfflineReady] = useState(state.offlineReady);
  useEffect(() => {
    const sync = (next: PwaRegisterState) => {
      setNeedRefresh(next.needRefresh);
      setOfflineReady(next.offlineReady);
    };
    setters.add(sync);
    return () => {
      setters.delete(sync);
    };
  }, []);
  return {
    needRefresh: [needRefresh, setNeedRefresh],
    offlineReady: [offlineReady, setOfflineReady],
    updateServiceWorker: updateServiceWorkerMock,
  };
};
```

Casos mínimos:
- `UpdatePrompt`: invisível com `needRefresh: false`; visível com `true`; "Atualizar" chama
  `updateServiceWorkerMock(true)`; "Agora não" esconde; falha mostra o erro e devolve os botões.
- `useAppUpdate`: com `vi.useFakeTimers()`, `registration.update()` é chamado a cada hora e ao voltar a
  aba para `visible`; não chama offline.
- `AppVersionRow`: mostra `v{APP_VERSION}`; mostra "Atualizar agora" só com `needRefresh`.

Opcional: script `scripts/check-pwa-build.mjs` (`npm run check:pwa`, depois do build) que confere o
`dist/manifest.webmanifest`, a existência/tamanho dos ícones, o `<link rel="manifest">` no `index.html` e
o `navigateFallbackDenylist` no `sw.js` (modelo no finami).

## 12. Proibido

- `registerType: "autoUpdate"` ou `skipWaiting` automático: o app recarrega no meio do uso, sem aviso.
- Registrar o SW em mais de um lugar ou habilitar o SW em dev.
- Colocar respostas da API no precache ou em `runtimeCaching`; servir `/api` pelo `navigateFallback`.
- Versão fixa no código ou lida do `package.json` como fonte principal (ela é só o último recurso).
- Aviso modal que bloqueia a tela ou rouba o foco.
- Cache longo em `sw.js`, `manifest.webmanifest` ou `index.html`.

## Checklist

- [ ] `vite-plugin-pwa` com `registerType: "prompt"`, `injectRegister: false`, `devOptions.enabled: false`
- [ ] Manifest com ícones `any` + `maskable` (192 e 512), `id`, `start_url`, `scope`, cores do design
- [ ] `navigateFallbackDenylist` com as rotas do backend; `cleanupOutdatedCaches: true`
- [ ] `__APP_VERSION__` definido no `vite.config.ts` (VITE_APP_VERSION → tag do git → package.json)
- [ ] `AppUpdateProvider` acima do roteador; `useRegisterSW` em um único lugar
- [ ] `UpdatePrompt` com Atualizar / Agora não, `role="status"`, verificação a cada hora e ao voltar à aba
- [ ] Linha **Versão** (`vX.Y.Z`) na tela de configurações/conta, com "Atualizar agora" quando houver versão nova
- [ ] Textos no i18n
- [ ] Dockerfile com `ARG VITE_APP_VERSION`; CI com `fetch-depth: 0` e o build arg
- [ ] nginx com `no-cache` no SW, manifest e `index.html`
- [ ] Testes com o mock de `virtual:pwa-register/react`
