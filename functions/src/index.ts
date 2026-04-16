import Anthropic from "@anthropic-ai/sdk";
import * as functions from "firebase-functions";

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

/**
 * 메시지 목록을 Claude API로 요약
 * firebase functions:config:set anthropic.api_key="YOUR_KEY" 로 키 설정
 */
export const summarizeMessages = functions.https.onCall(async (data) => {
  const messages: string[] = data.messages;
  if (!messages?.length) throw new functions.https.HttpsError("invalid-argument", "messages required");

  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 1024,
    messages: [
      {
        role: "user",
        content: `다음 대화 내용을 업무 보고서 형식으로 간결하게 요약해줘:\n\n${messages.join("\n")}`,
      },
    ],
  });

  const summary = response.content[0].type === "text" ? response.content[0].text : "";
  return { summary };
});

/**
 * 메시지 내용으로 태그 자동 추천
 */
export const suggestTags = functions.https.onCall(async (data) => {
  const content: string = data.content;
  if (!content) throw new functions.https.HttpsError("invalid-argument", "content required");

  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 256,
    messages: [
      {
        role: "user",
        content: `다음 메시지에 어울리는 업무 태그를 최대 5개 추천해줘. JSON 배열 형식으로만 응답해:\n\n${content}`,
      },
    ],
  });

  const text = response.content[0].type === "text" ? response.content[0].text : "[]";
  const tags = JSON.parse(text);
  return { tags };
});
