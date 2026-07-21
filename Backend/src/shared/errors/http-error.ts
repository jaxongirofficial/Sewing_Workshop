export class HttpError extends Error {
  constructor(
    public readonly statusCode: number,
    message: string,
    public readonly code = 'HTTP_ERROR',
    public readonly details: string[] = [],
  ) {
    super(message);
    this.name = 'HttpError';
  }
}
