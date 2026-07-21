export interface SuccessResponse<T> {
  success: true;
  message: string;
  data: T;
}

export interface ErrorResponse {
  success: false;
  message: string;
  errors: string[];
}

export const successResponse = <T>(data: T, message = 'Success'): SuccessResponse<T> => ({
  success: true,
  message,
  data,
});

export const errorResponse = (message: string, errors: string[] = []): ErrorResponse => ({
  success: false,
  message,
  errors,
});
