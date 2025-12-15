import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('markdown-it-gfm-cjk-friendly converter', () => {
    beforeEach(() => {
        vi.resetModules();
    });

    it('should throw if setup is not called', async () => {
        const { convertMarkdownToHtml } = await import('./markdown-it-gfm-cjk-friendly');
        expect(() => convertMarkdownToHtml('# Hello')).toThrow('markdown-it options not initialized');
    });

    it('should setup and convert markdown with CJK friendly features', async () => {
        const { setup, convertMarkdownToHtml } = await import('./markdown-it-gfm-cjk-friendly');
        setup({});
        const html = convertMarkdownToHtml('# Hello');
        expect(html).toContain('<h1>Hello</h1>');
    });

    it('should throw if setup is called with null options', async () => {
        const { setup } = await import('./markdown-it-gfm-cjk-friendly');
        // @ts-ignore
        expect(() => setup(null)).toThrow('markdown-it options are required');
    });
});
