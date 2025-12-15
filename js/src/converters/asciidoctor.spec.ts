import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('asciidoctor converter', () => {
    beforeEach(() => {
        vi.resetModules();
    });

    it('should convert asciidoc to html', async () => {
        const { convertAsciiDocToHtml } = await import('./asciidoctor');
        const html = convertAsciiDocToHtml('Hello World');
        expect(html).toContain('<p>Hello World</p>');
    });

    it('should respect setup options', async () => {
        const { setup, convertAsciiDocToHtml } = await import('./asciidoctor');
        // Example option: header_footer: false (default is false for convert method usually, but let's check basic function)
        setup({ processorOptions: { attributes: { showtitle: true } } });
        const html = convertAsciiDocToHtml('= Hello World');
        expect(html).toContain('<h1>Hello World</h1>');
    });
});
