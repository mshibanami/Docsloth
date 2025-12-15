import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('markdown-it converter', () => {
    beforeEach(() => {
        vi.resetModules();
    });

    it('should throw if setup is not called', async () => {
        const { convertMarkdownToHtml } = await import('./markdown-it');
        expect(() => convertMarkdownToHtml('# Hello')).toThrow('markdown-it options not initialized');
    });

    it('should setup and convert markdown', async () => {
        const { setup, convertMarkdownToHtml } = await import('./markdown-it');
        setup({});
        const html = convertMarkdownToHtml('# Hello');
        expect(html).toContain('<h1>Hello</h1>');
    });

    it('should throw if setup is called with null options', async () => {
        const { setup } = await import('./markdown-it');
        // @ts-ignore
        expect(() => setup(null)).toThrow('markdown-it options are required');
    });
});
