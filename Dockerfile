# 1. Dependencias
FROM node:22.12-alpine AS deps
WORKDIR /app

# Habilitar pnpm vía corepack o npm
RUN npm install -g pnpm

# Copiar configuración de dependencias y workspace
COPY package.json pnpm-lock.yaml* pnpm-workspace.yaml* ./

# Instalar dependencias respetando el lockfile
RUN pnpm install --frozen-lockfile

# 2. Construcción
FROM deps AS builder
WORKDIR /app

# Copiar el código fuente
COPY . .

# Construir el sitio estático de Astro
RUN pnpm run build

# 3. Producción (Servidor Web Nginx ligero)
FROM nginx:alpine AS runner

# Copiar el build compilado al directorio de Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80 del contenedor
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]