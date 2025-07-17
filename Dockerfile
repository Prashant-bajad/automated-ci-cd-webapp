# Stage 1: Build Stage (Optional but good practice for larger apps)
# Humein sirf production dependencies chahiye, development wali nahi.
# Upar se ek Node.js base image pull karein.
FROM node:18-alpine AS build

# Working directory set karein container ke andar.
WORKDIR /app

# package.json aur package-lock.json files ko working directory mein copy karein.
# Ye step caching ke liye optimize kiya gaya hai.
COPY package*.json ./

# Dependencies install karein.
RUN npm install --production

# Baaki application code copy karein.
COPY . .

# Stage 2: Production Stage (Smaller image for deployment)
FROM node:18-alpine

# Working directory set karein.
WORKDIR /app

# Build stage se production dependencies copy karein.
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/index.js ./index.js
COPY --from=build /app/package.json ./package.json 
# package.json bhi chahiye run karne ke liye

# Port expose karein jahan application listen karegi. Ye sirf documentation ke liye hai.
EXPOSE 3000

# Application ko run karne ke liye default command define karein.
CMD ["node", "index.js"]