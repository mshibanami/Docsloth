import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('markdown-it-gfm converter', () => {
    beforeEach(() => {
        vi.resetModules();
    });

    it('should throw if setup is not called', async () => {
        const { convertMarkdownToHtml } = await import('./markdown-it-gfm');
        expect(() => convertMarkdownToHtml('# Hello')).toThrow('markdown-it options not initialized');
    });

    it('should setup and convert markdown with GFM features', async () => {
        const { setup, convertMarkdownToHtml } = await import('./markdown-it-gfm');
        setup({});

        // Task list
        const taskListHtml = convertMarkdownToHtml('- [ ] task');
        expect(taskListHtml).toContain('type="checkbox"');

        // Strikethrough
        const strikethroughHtml = convertMarkdownToHtml('~~strikethrough~~');
        expect(strikethroughHtml).toContain('<s>strikethrough</s>');
    });

    it('should throw if setup is called with null options', async () => {
        const { setup } = await import('./markdown-it-gfm');
        // @ts-ignore
        expect(() => setup(null)).toThrow('markdown-it options are required');
    });
});
