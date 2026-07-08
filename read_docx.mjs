import fs from 'fs';
import mammoth from 'mammoth';

const path = process.argv[2];
if (!path) {
  console.error('Usage: node read_docx.mjs <docx-path>');
  process.exit(1);
}

const result = await mammoth.extractRawText({ path });
console.log(result.value);
