const fs = require('fs');
const openai = require('../config/openai');

/**
 * Transcribe audio file using OpenAI Whisper API
 */
async function transcribeAudio(audioFilePath) {
  const transcription = await openai.audio.transcriptions.create({
    file: fs.createReadStream(audioFilePath),
    model: 'whisper-1',
    language: 'en',
  });
  return transcription.text;
}

/**
 * Analyze speech and generate detailed feedback using GPT-4
 */
async function analyzeSpeech(transcript, topicTitle, topicPrompt, questions) {
  const systemPrompt = `You are an expert English speaking coach and IELTS examiner. 
Analyze the student's spoken response and provide detailed, constructive feedback.
You MUST respond with valid JSON only, no markdown or extra text.

The JSON must have this exact structure:
{
  "overall": <number 0-10>,
  "fluency": <number 0-10>,
  "pronunciation": <number 0-10>,
  "grammar": <number 0-10>,
  "vocabulary": <number 0-10>,
  "coherence": <number 0-10>,
  "strengths": ["strength1", "strength2", ...],
  "issues": ["issue1", "issue2", ...],
  "suggestions": ["suggestion1", "suggestion2", ...]
}

Scoring criteria:
- fluency: Flow and natural pace of speech, minimal hesitation
- pronunciation: Clarity and correctness of pronunciation
- grammar: Accuracy of grammatical structures used
- vocabulary: Range and appropriateness of vocabulary
- coherence: Logical organization and connection of ideas
- overall: Weighted average considering all aspects

Provide 2-4 items for strengths, issues, and suggestions.
All feedback text should be in Vietnamese (Tiếng Việt).`;

  const userPrompt = `Topic: "${topicTitle}"
Prompt: "${topicPrompt}"
${questions && questions.length > 0 ? `Questions: ${questions.join(', ')}` : ''}

Student's transcript:
"${transcript}"

Analyze this response and provide JSON feedback.`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    temperature: 0.3,
    response_format: { type: 'json_object' },
  });

  const content = response.choices[0].message.content;
  return JSON.parse(content);
}

/**
 * Generate topic suggestions using GPT-4
 */
async function generateTopicSuggestions(level, count = 3) {
  const systemPrompt = `You are an expert English speaking coach.
Generate speaking practice topics for students.
Respond with valid JSON only.

The JSON must be an array of topic objects:
[
  {
    "title": "Topic title in Vietnamese",
    "prompt": "Detailed description/context in Vietnamese",
    "questions": ["Question 1 in English", "Question 2 in English", "Question 3 in English"],
    "tags": ["tag1", "tag2"],
    "duration": "3-5 phút"
  }
]`;

  const levelMap = {
    beginner: 'Beginner (A1-A2)',
    intermediate: 'Intermediate (B1-B2)',
    advanced: 'Advanced (C1-C2)',
  };

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: systemPrompt },
      {
        role: 'user',
        content: `Generate ${count} English speaking practice topics for ${levelMap[level] || 'Intermediate'} level students. Topics should be engaging and practical.`,
      },
    ],
    temperature: 0.8,
    response_format: { type: 'json_object' },
  });

  const content = response.choices[0].message.content;
  const parsed = JSON.parse(content);
  // Handle both {topics: [...]} and [...] formats
  return Array.isArray(parsed) ? parsed : parsed.topics || [];
}

module.exports = {
  transcribeAudio,
  analyzeSpeech,
  generateTopicSuggestions,
};
