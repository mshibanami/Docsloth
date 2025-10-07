import type { AsciidoctorOptions } from "@/types/asciidoctor-options";
import asciidoctor, { type ProcessorOptions } from "asciidoctor";

const Asciidoctor = asciidoctor();
var processorOptions: ProcessorOptions | undefined;

export function setup(options: AsciidoctorOptions) {
    processorOptions = options.processorOptions;
    // No setup needed for Asciidoctor as of now.
}

export function convertAsciiDocToHtml(asciiDoc: string): string {
    return Asciidoctor.convert(asciiDoc, processorOptions) as string;
}
