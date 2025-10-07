import { defineConfig } from 'vite';
import tsconfigPaths from 'vite-tsconfig-paths';
import license from 'rollup-plugin-license';
import path from 'path';

export default defineConfig(() => {
    const converter = getConverter();
    console.log(`Building for converter: ${converter}`);
    return ({
        plugins: [
            tsconfigPaths(),
            license({
                thirdParty: {
                    output: {
                        file: path.join(__dirname, 'dist', converter + '.notice.json'),
                        template(dependencies) {
                            return JSON.stringify(dependencies, null, 2);
                        }
                    },
                },
            }),
        ],
        build: {
            lib: {
                entry: 'src/entrypoints/' + converter + '.ts',
                name: 'Docsloth',
                fileName: (format) => `${converter}.${format}.js`,
                formats: ['iife'],
            },
            target: 'esnext',
            minify: 'esbuild',
            sourcemap: false,
            cssCodeSplit: false,
            emptyOutDir: false,
            rollupOptions: {
                output: {
                    inlineDynamicImports: true,
                    manualChunks: undefined,
                },
            },
        },
        esbuild: {
            legalComments: 'none',
        },
    });
});

const SupportedConverter = {
    markdownIt: 'markdown-it',
    markdownItGfm: 'markdown-it-gfm',
    markdownItGfmCjkFriendly: 'markdown-it-gfm-cjk-friendly',
    asciidoctor: 'asciidoctor',
} as const;
type SupportedConverter = typeof SupportedConverter[keyof typeof SupportedConverter];

function getConverter(): SupportedConverter {
    const converter = process.env.CONVERTER as SupportedConverter | undefined;
    if (converter === undefined) {
        throw new Error('CONVERTER environment variable is not set.');
    }
    switch (converter) {
        case SupportedConverter.markdownIt:
            return SupportedConverter.markdownIt;
        case SupportedConverter.markdownItGfm:
            return SupportedConverter.markdownItGfm;
        case SupportedConverter.markdownItGfmCjkFriendly:
            return SupportedConverter.markdownItGfmCjkFriendly;
        case SupportedConverter.asciidoctor:
            return SupportedConverter.asciidoctor;
        default:
            const _exhaustiveCheck: never = converter;
            throw new Error('CONVERTER environment variable must be set to one of: ' + Object.values(SupportedConverter).join(', '));
    }
}
