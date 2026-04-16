import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  webpack: (config) => {
    // This forces the use of Webpack because Turbopack 
    // does not yet support custom webpack configs.
    return config;
  },
};

export default nextConfig;
